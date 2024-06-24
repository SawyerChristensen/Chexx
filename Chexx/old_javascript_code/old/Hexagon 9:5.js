import React from 'react';
import {Image as RNImage } from 'react-native';
import { Polygon } from 'react-native-svg';
import whitePawn from '../assets/images/white_pawn.png';
import blackPawn from '../assets/images/black_pawn.png';
import whiteRook from '../assets/images/white_rook.png';
import blackRook from '../assets/images/black_rook.png';
import whiteKnight from '../assets/images/white_knight.png';
import blackKnight from '../assets/images/black_knight.png';
import whiteBishop from '../assets/images/white_bishop.png';
import blackBishop from '../assets/images/black_bishop.png';
import whiteQueen from '../assets/images/white_queen.png';
import blackQueen from '../assets/images/black_queen.png';
import whiteKing from '../assets/images/white_king.png';
import blackKing from '../assets/images/black_king.png';

function calculateHexagonPoints(centerX, centerY, radius) {
  const points = [];

  for (let i = 0; i < 6; i++) {
    const angle = (Math.PI / 3) * i;
    const x = centerX + radius * Math.cos(angle);
    const y = centerY + radius * Math.sin(angle);
    points.push(`${x},${y}`);
  }

  return points.join(' ');
};

const Hexagon = ({ x, y, radius, color, piece }) => {
  const points = calculateHexagonPoints(x, y, radius);

  let pieceImage = null;

  switch(piece) {
    case 'white_pawn':
      pieceImage = <RNImage style={{ position: 'absolute', left: x - radius * 0.75, top: y - radius * 0.8, width: radius * 1.5, height: radius * 1.5 }} source={whitePawn} />;
      break;
    case 'black_pawn':
      pieceImage = <RNImage style={{ position: 'absolute', left: x - radius * 0.75, top: y - radius * 0.8, width: radius * 1.5, height: radius * 1.5 }} source={blackPawn} />;
      break;
    case 'white_rook':
      pieceImage = <RNImage style={{ position: 'absolute', left: x - radius * 0.75, top: y - radius * 0.8, width: radius * 1.5, height: radius * 1.5 }} source={whiteRook} />;
      break;
    case 'black_rook':
      pieceImage = <RNImage style={{ position: 'absolute', left: x - radius * 0.75, top: y - radius * 0.8, width: radius * 1.5, height: radius * 1.5 }} source={blackRook} />;
      break;
    case 'white_knight':
      pieceImage = <RNImage style={{ position: 'absolute', left: x - radius * 0.75, top: y - radius * 0.8, width: radius * 1.5, height: radius * 1.5 }} source={whiteKnight} />;
      break;
    case 'black_knight':
      pieceImage = <RNImage style={{ position: 'absolute', left: x - radius * 0.75, top: y - radius * 0.8, width: radius * 1.5, height: radius * 1.5 }} source={blackKnight} />;
      break;
    case 'white_bishop':
      pieceImage = <RNImage style={{ position: 'absolute', left: x - radius * 0.75, top: y - radius * 0.8, width: radius * 1.5, height: radius * 1.5 }} source={whiteBishop} />;
      break;
    case 'black_bishop':
      pieceImage = <RNImage style={{ position: 'absolute', left: x - radius * 0.75, top: y - radius * 0.8, width: radius * 1.5, height: radius * 1.5 }} source={blackBishop} />;
      break;
    case 'white_queen':
      pieceImage = <RNImage style={{ position: 'absolute', left: x - radius * 0.75, top: y - radius * 0.8, width: radius * 1.5, height: radius * 1.5 }} source={whiteQueen} />;
      break;
    case 'black_queen':
      pieceImage = <RNImage style={{ position: 'absolute', left: x - radius * 0.75, top: y - radius * 0.8, width: radius * 1.5, height: radius * 1.5 }} source={blackQueen} />;
      break;
    case 'white_king':
      pieceImage = <RNImage style={{ position: 'absolute', left: x - radius * 0.75, top: y - radius * 0.8, width: radius * 1.5, height: radius * 1.5 }} source={whiteKing} />;
      break;
    case 'black_king':
      pieceImage = <RNImage style={{ position: 'absolute', left: x - radius * 0.75, top: y - radius * 0.8, width: radius * 1.5, height: radius * 1.5 }} source={blackKing} />;
      break;
    default:
      break;
  }

  return (
    <>
      <Polygon points={points} fill={color} />
      {pieceImage}
    </>
  );
};

export default Hexagon;