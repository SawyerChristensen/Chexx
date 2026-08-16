#!/usr/bin/env python3
"""
Trains a small linear piece-square-table (PST) evaluation function for GameCPU offline,
using the self-play dataset produced by ChexxTests/SelfPlayGenerator.swift +
TrainingDataExtractor.swift (see ~/DeckedOutCollection/ChexxSelfPlayDataset.md).

No external ML framework — plain gradient descent over a table of
weight[color][pieceType][squareIndex], one weight per piece/color/square (91 hex tiles,
GameState.boardIndex(col:row:) order, matching the "board" field in the dataset).

Weights are initialized to the existing material-only values from GameState.swift's
pieceValue(_:), so an untrained/undertrained model degrades gracefully to today's
material-only evaluator, and an L2 penalty pulls weights back toward that prior to keep
a ~550-record dataset from overfitting into nonsense.

Usage:
    python3 scripts/train_eval_weights.py \
        --input ~/DeckedOutCollection/ChexxSelfPlayDataset.jsonl \
        --output ~/DeckedOutCollection/ChexxLearnedEvalWeights.json
"""

import argparse
import json
import math
import os
import random

SQUARE_COUNT = 91  # Glinski's hexchess board (GameState.tileCount)
PIECE_TYPES = ["pawn", "knight", "bishop", "rook", "queen", "king"]
COLORS = ["white", "black"]

# Mirrors GameState.swift's pieceValue(_:) — the current material-only evaluator this
# model's weights are initialized from and regularized toward.
MATERIAL_PRIOR = {
    "pawn": 1,
    "knight": 3,
    "bishop": 3,
    "rook": 5,
    "queen": 9,
    "king": 1000,
}


def load_records(path):
    records = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            records.append(json.loads(line))
    return records


def new_weight_table(prior):
    return {color: {piece: [float(prior[piece])] * SQUARE_COUNT for piece in PIECE_TYPES} for color in COLORS}


def score(board, weights):
    total = 0.0
    for square_index, entry in enumerate(board):
        if not entry:
            continue
        color, piece_type = entry.split("_", 1)
        w = weights[color][piece_type][square_index]
        total += w if color == "white" else -w
    return total


def sigmoid(x):
    # Guard against overflow for large |x| (king weight ~1000 dwarfs everything else).
    if x >= 0:
        z = math.exp(-x)
        return 1.0 / (1.0 + z)
    z = math.exp(x)
    return z / (1.0 + z)


def train(records, weights, prior, temperature, epochs, lr, l2, seed):
    rng = random.Random(seed)
    order = list(range(len(records)))
    history = []
    for epoch in range(epochs):
        rng.shuffle(order)
        total_loss = 0.0
        for i in order:
            record = records[i]
            board = record["board"]
            target = float(record["value"])

            raw_score = score(board, weights)
            pred = sigmoid(raw_score / temperature)
            error = pred - target
            total_loss += error * error

            # d(error^2)/d(raw_score) = 2*error*pred*(1-pred), then chain through /temperature.
            d_loss_d_score = 2.0 * error * pred * (1.0 - pred) / temperature

            for square_index, entry in enumerate(board):
                if not entry:
                    continue
                color, piece_type = entry.split("_", 1)
                grad = d_loss_d_score if color == "white" else -d_loss_d_score
                current = weights[color][piece_type][square_index]
                reg = 2.0 * l2 * (current - prior[piece_type])
                weights[color][piece_type][square_index] = current - lr * (grad + reg)

        mean_loss = total_loss / len(records)
        history.append(mean_loss)
    return history


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", default=os.path.expanduser("~/DeckedOutCollection/ChexxSelfPlayDataset.jsonl"))
    parser.add_argument("--output", default=os.path.expanduser("~/DeckedOutCollection/ChexxLearnedEvalWeights.json"))
    parser.add_argument("--epochs", type=int, default=300)
    parser.add_argument("--lr", type=float, default=0.02)
    parser.add_argument("--l2", type=float, default=0.0005)
    parser.add_argument("--temperature", type=float, default=8.0)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    records = load_records(args.input)
    if not records:
        raise SystemExit(f"No training records found in {args.input}")

    weights = new_weight_table(MATERIAL_PRIOR)
    history = train(
        records,
        weights,
        MATERIAL_PRIOR,
        temperature=args.temperature,
        epochs=args.epochs,
        lr=args.lr,
        l2=args.l2,
        seed=args.seed,
    )

    output = {
        "meta": {
            "description": "Learned piece-square-table weights for GameCPU.evaluateGameState, "
                            "trained offline on Chexx self-play data. See "
                            "~/DeckedOutCollection/ChexxSelfPlayDataset.md and TO DO.md's "
                            "\"Add AI components to CPU?\" section for context.",
            "squareOrder": "GameState.boardIndex(col:row:) flat index, 0..90",
            "pieceTypes": PIECE_TYPES,
            "colors": COLORS,
            "materialPrior": MATERIAL_PRIOR,
            "trainingRecordCount": len(records),
            "inputDataset": os.path.abspath(os.path.expanduser(args.input)),
            "hyperparameters": {
                "epochs": args.epochs,
                "learningRate": args.lr,
                "l2": args.l2,
                "temperature": args.temperature,
                "seed": args.seed,
            },
            "initialMeanSquaredError": history[0],
            "finalMeanSquaredError": history[-1],
        },
        "weights": weights,
    }

    output_path = os.path.abspath(os.path.expanduser(args.output))
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w") as f:
        json.dump(output, f, indent=2)

    print(f"Trained on {len(records)} records for {args.epochs} epochs.")
    print(f"Mean squared error: {history[0]:.4f} -> {history[-1]:.4f}")
    print(f"Wrote weights to {output_path}")


if __name__ == "__main__":
    main()
