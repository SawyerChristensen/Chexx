import React, { useCallback, useEffect, useState } from 'react';
import {Image} from 'react-native';
import {PanGestureHandler} from 'react-native-gesture-handler';
import Animated, {
    runOnJS,
    useAnimatedGestureHandler,
    useAnimatedStyle,
    useSharedValue,
    withTiming,
  } from "react-native-reanimated";
//import HexChessGame from './GameEngine';
import {hexTiles} from './Background';
import { splitKey } from './UtilityFunctions';

function distance(p1, p2) {
    return Math.sqrt((p1.x - p2.x) ** 2 + (p1.y - p2.y) ** 2);
}

function closestHexCenter(x, y, hexCenters) { //returns an {x , y} coordinate
    let closestDistance = Infinity;
    let closestCenter = null;

    for (const center of hexCenters) {
        const d = distance({ x, y }, center);
        if (d < closestDistance) {
            closestDistance = d;
            closestCenter = center;
        }
    }
    return closestCenter;
}

const radius = 18.75; //needs to be fixed later!!!! hardcoded for now. import dimensions and radius from some settings file?

const pieceImages = {
    'white_pawn': require('../assets/images/white_pawn.png'),
    'black_pawn': require('../assets/images/black_pawn.png'),
    'white_rook': require('../assets/images/white_rook.png'),
    'black_rook': require('../assets/images/black_rook.png'),
    'white_knight': require('../assets/images/white_knight.png'),
    'black_knight': require('../assets/images/black_knight.png'),
    'white_bishop': require('../assets/images/white_bishop.png'),
    'black_bishop': require('../assets/images/black_bishop.png'),
    'white_queen': require('../assets/images/white_queen.png'),
    'black_queen': require('../assets/images/black_queen.png'),
    'white_king': require('../assets/images/white_king.png'),
    'black_king': require('../assets/images/black_king.png'),
};

const Piece = ({ column, row, color, type, startingX, startingY }) => {
    //the individual image, individual image styling
    const imageSource = pieceImages[`${color}_${type}`];
    const pieceStyle = {
        position: 'absolute',
        left: -radius * 0.75,
        top: -radius * 0.8,
        width: radius * 1.5,
        height: radius * 1.5
    };

    const offsetX = useSharedValue(0);
    const offsetY = useSharedValue(0);
    const translateX = useSharedValue(startingX);
    const translateY = useSharedValue(startingY);

    const movePiece = useCallback((fromPosition, toPosition) => {
        //define target tile, first x,y then key
        const hexCenters = hexTiles.map(hex => ({
            key: hex.key,
            x: hex.props.x, 
            y: hex.props.y
        }));

        targetPosition = closestHexCenter(toPosition.x, toPosition.y, hexCenters);
        const {columnLetter, rowIndex} = splitKey(targetPosition.key);
        console.log("current position: ", column, row);
        console.log("target position: ", columnLetter, rowIndex);

        //if it is a valid tile to move to, move to it and update board state
        const validMoves = gameInstance.validMoveList({color, type}, column, row);
        console.log("valid moves: ", validMoves);
        if (validMoves.some(move => move[0] === columnLetter && move[1] === rowIndex)) {

            const newBoardState = {...gameInstance.boardState};
            newBoardState[columnLetter][rowIndex] = {color, type};
            newBoardState[column][row] = {color: "none", type: "none"};
            //gameInstance.switchPlayer();

            // animate to the closest hex center
            translateX.value = withTiming(targetPosition.x);
            translateY.value = withTiming(targetPosition.y);

            gameInstance.boardState = newBoardState; // Update the external game instance.
            setBoardState({ board: newBoardState });  // Update the React state.

        } else {
            // If move is not valid, revert piece back to its original position
            translateX.value = withTiming(fromPosition.x);
            translateY.value = withTiming(fromPosition.y);
        }
        }
    );

    const onGestureEvent = useAnimatedGestureHandler({
        onStart: () => {
            offsetX.value = translateX.value;
            offsetY.value = translateY.value;
        },
        onActive: ({translationX, translationY}) => {
            translateX.value = translationX + offsetX.value;
            translateY.value = translationY + offsetY.value;
        },
        onEnd: () => {
            const fromPosition = ({x: offsetX.value, y: offsetY.value});
            const toPosition = ({x: translateX.value, y: translateY.value});
            runOnJS(movePiece)(fromPosition, toPosition);
        }
    });

    const animatedStyle = useAnimatedStyle(() => ({
        position: "absolute",
        width: radius,
        height: radius,
        transform: [
        {translateX: translateX.value},
        {translateY: translateY.value}
        ]
    }));
    
    return (
        <PanGestureHandler onGestureEvent={onGestureEvent}>
            <Animated.View style={animatedStyle}>
                <Image source={imageSource} style={pieceStyle}/>
            </Animated.View>
        </PanGestureHandler>
    );
};

export default Piece