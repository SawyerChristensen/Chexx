import React, { useEffect, useState } from 'react';
import { Dimensions, View, StyleSheet } from 'react-native';
import Svg from 'react-native-svg';
import Hexagon from './Hexagon';
import { light, grey, dark } from './Settings';
import { calculateNewCenter } from './UtilityFunctions';
import Piece from './Piece';

/*
class GameBoard {
  constructor() {
    this.board = {
      'a': Array(6).fill(null),
      'b': Array(7).fill(null),
      'c': Array(8).fill(null),
      'd': Array(9).fill(null),
      'e': Array(10).fill(null),
      'f': Array(11).fill(null),
      'g': Array(10).fill(null),
      'h': Array(9).fill(null),
      'i': Array(8).fill(null),
      'k': Array(7).fill(null),
      'l': Array(6).fill(null),
    }
  }

  placePiece(column, row, piece) {
    if (!this.board.hasOwnProperty(column) || row >= this.board[column].length) {
      throw new Error("Invalid position");
    }
   this.board[column][row] = piece;
  }

  getPiece(column, row) {
   if (!this.board.hasOwnProperty(column) || row >= this.board[column].length) {
      return null;
   }
   return this.board[column][row];
  }
}*/


const Board = () => {

  const { width, height } = Dimensions.get('window');
  const smallerDimension = Math.min(width, height);
  const radius = smallerDimension * 0.05;
  let currentX = width / 2;
  let currentY = height / 2;

  const hexagons = [];
  const pieces = [];

  // Start with center hexagon
  hexagons.push(<Hexagon key="f6" x={currentX} y={currentY} radius={radius} color={grey} piece={gameBoard.getPiece('f', 6)} />);

  // Draw hexagon above center
  let newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="f7" x={currentX} y={currentY} radius={radius} color={light} piece={gameBoard.getPiece('f', 7)}/>);
/*
  // Draw hexagon to the bottom left of the last one
  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="e6" x={currentX} y={currentY} radius={radius} color={dark} piece={'black_pawn'}/>);

  // and so on
  newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="e5" x={currentX} y={currentY} radius={radius} color={light} piece={'black_pawn'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="f5" x={currentX} y={currentY} radius={radius} color={dark} piece={'black_pawn'} />);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="g5" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="g6" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="g7" x={currentX} y={currentY} radius={radius} color={grey} piece={'black_pawn'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="f8" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="e7" x={currentX} y={currentY} radius={radius} color={grey} piece={'black_pawn'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="d6" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="d5" x={currentX} y={currentY} radius={radius} color={grey} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="d4" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="e4" x={currentX} y={currentY} radius={radius} color={grey} piece={'white_pawn'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="f4" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="g4" x={currentX} y={currentY} radius={radius} color={grey} piece={'white_pawn'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="h4" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="h5" x={currentX} y={currentY} radius={radius} color={grey} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="h6" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="h7" x={currentX} y={currentY} radius={radius} color={dark} piece={'black_pawn'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="g8" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="f9" x={currentX} y={currentY} radius={radius} color={grey} piece={'black_bishop'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="e8" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="d7" x={currentX} y={currentY} radius={radius} color={dark} piece={'black_pawn'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="c6" x={currentX} y={currentY} radius={radius} color={grey} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="c5" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="c4" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="c3" x={currentX} y={currentY} radius={radius} color={grey} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="d3" x={currentX} y={currentY} radius={radius} color={light} piece={'white_pawn'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="e3" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="f3" x={currentX} y={currentY} radius={radius} color={grey} piece={'white_bishop'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="g3" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="h3" x={currentX} y={currentY} radius={radius} color={light} piece={'white_pawn'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="i3" x={currentX} y={currentY} radius={radius} color={grey} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="i4" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="i5" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="i6" x={currentX} y={currentY} radius={radius} color={grey} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="i7" x={currentX} y={currentY} radius={radius} color={light} piece={'black_pawn'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="h8" x={currentX} y={currentY} radius={radius} color={grey} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="g9" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="f10" x={currentX} y={currentY} radius={radius} color={light} piece={'black_bishop'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="e9" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="d8" x={currentX} y={currentY} radius={radius} color={grey} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="c7" x={currentX} y={currentY} radius={radius} color={light} piece={'black_pawn'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="b6" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="b5" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="b4" x={currentX} y={currentY} radius={radius} color={grey} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="b3" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="b2" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="c2" x={currentX} y={currentY} radius={radius} color={dark} piece={'white_pawn'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="d2" x={currentX} y={currentY} radius={radius} color={grey} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="e2" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="f2" x={currentX} y={currentY} radius={radius} color={dark} piece={'white_bishop'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="g2" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="h2" x={currentX} y={currentY} radius={radius} color={grey} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="i2" x={currentX} y={currentY} radius={radius} color={dark} piece={'white_pawn'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="k2" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="k3" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="k4" x={currentX} y={currentY} radius={radius} color={grey} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="k5" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="k6" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="k7" x={currentX} y={currentY} radius={radius} color={grey} piece={'black_pawn'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="i8" x={currentX} y={currentY} radius={radius} color={dark} piece={'black_rook'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="h9" x={currentX} y={currentY} radius={radius} color={light} piece={'black_knight'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="g10" x={currentX} y={currentY} radius={radius} color={grey} piece={'black_king'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="f11" x={currentX} y={currentY} radius={radius} color={dark} piece={'black_bishop'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="e10" x={currentX} y={currentY} radius={radius} color={grey} piece={'black_queen'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="d9" x={currentX} y={currentY} radius={radius} color={light} piece={'black_knight'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="c8" x={currentX} y={currentY} radius={radius} color={dark} piece={'black_rook'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="b7" x={currentX} y={currentY} radius={radius} color={grey} piece={'black_pawn'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="a6" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="a5" x={currentX} y={currentY} radius={radius} color={grey} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="a4" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="a3" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="a2" x={currentX} y={currentY} radius={radius} color={grey} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="a1" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="b1" x={currentX} y={currentY} radius={radius} color={grey} piece={'white_pawn'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="c1" x={currentX} y={currentY} radius={radius} color={light} piece={'white_rook'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="d1" x={currentX} y={currentY} radius={radius} color={dark} piece={'white_knight'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="e1" x={currentX} y={currentY} radius={radius} color={grey} piece={'white_queen'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="f1" x={currentX} y={currentY} radius={radius} color={light} piece={'white_bishop'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="g1" x={currentX} y={currentY} radius={radius} color={grey} piece={'white_king'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="h1" x={currentX} y={currentY} radius={radius} color={dark} piece={'white_knight'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="i1" x={currentX} y={currentY} radius={radius} color={light} piece={'white_rook'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="k1" x={currentX} y={currentY} radius={radius} color={grey} piece={'white_pawn'}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="l1" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="l2" x={currentX} y={currentY} radius={radius} color={grey} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="l3" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="l4" x={currentX} y={currentY} radius={radius} color={dark} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="l5" x={currentX} y={currentY} radius={radius} color={grey} piece={null}/>);

  newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
  hexagons.push(<Hexagon key="l6" x={currentX} y={currentY} radius={radius} color={light} piece={null}/>);
*/

  return (
    <View style={styles.container}>
      <Svg height={height} width={width}>
        {hexagons}
        {pieces}
      </Svg>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});

export default Board;
