import React, { useEffect, useState } from 'react';
import { Dimensions, View, StyleSheet, PanResponder } from 'react-native';
import Svg from 'react-native-svg';
import Hexagon from './Hexagon';
import { light, grey, dark } from './Settings';
import { calculateNewCenter } from './UtilityFunctions';
import Piece from './Piece';


class GameBoard {
  constructor() {
    this.boardState = this.initializeBoard();
    this.gameStatus = 'ongoing';
    // ... any other initializations
  }

  initializeBoard() {
    return {
      "f11": { type: "pawn", color: "white" },
      "e7": { type: "king", color: "black" },
      //... other pieces and positions
    };
  }

  validMoveList(piece, startingPosition) {
    // Check if a move is valid
  }

  isValidMove(position) { //returns a bool
    //if position is in validMoveList, then it is valid
    //if not, it is not a valid move
  }

  movePiece(piece, targetPosition) {
    if (this.isValidMove(piece, targetPosition)) {
      // Update the boardState with the piece's new position
      // Possibly trigger other events like captures, etc.
    }
  }

  getGameStatus() {
    // Check and return the current status of the game
    return this.gameStatus;
  }

  // ... other game-related methods
}



const Board = () => {
  const { width, height } = Dimensions.get('window');
  const smallerDimension = Math.min(width, height);
  const radius = smallerDimension * 0.05;

  // Instantiate the GameBoard class
  const gameBoard = new GameBoard();

  const generateHexTiles = (centerX, centerY, radius) => {

    // hexagon array that will be pushed to and rendered in the file return function
    const hexagons = [];

    // Start with center hexagon
    hexagons.push(<Hexagon key="f6" x={centerX} y={centerY} radius={radius} color={grey} />);

    // Draw hexagon above center
    let newCenter = calculateNewCenter(centerX, centerY, radius, 'above'); 
    currentX = newCenter.x; 
    currentY = newCenter.y;
    hexagons.push(<Hexagon key="f7" x={currentX} y={currentY} radius={radius} color={light}/>);

    // and so on
    newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); 
    currentX = newCenter.x; 
    currentY = newCenter.y;
    hexagons.push(<Hexagon key="e6" x={currentX} y={currentY} radius={radius} color={dark}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="e5" x={currentX} y={currentY} radius={radius} color={light}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="f5" x={currentX} y={currentY} radius={radius} color={dark}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="g5" x={currentX} y={currentY} radius={radius} color={light}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="g6" x={currentX} y={currentY} radius={radius} color={dark}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="g7" x={currentX} y={currentY} radius={radius} color={grey}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'upperLeft'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="f8" x={currentX} y={currentY} radius={radius} color={dark}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="e7" x={currentX} y={currentY} radius={radius} color={grey}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="d6" x={currentX} y={currentY} radius={radius} color={light}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="d5" x={currentX} y={currentY} radius={radius} color={grey}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="d4" x={currentX} y={currentY} radius={radius} color={dark}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="e4" x={currentX} y={currentY} radius={radius} color={grey}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="f4" x={currentX} y={currentY} radius={radius} color={light}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="g4" x={currentX} y={currentY} radius={radius} color={grey}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="h4" x={currentX} y={currentY} radius={radius} color={dark}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="h5" x={currentX} y={currentY} radius={radius} color={grey}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="h6" x={currentX} y={currentY} radius={radius} color={light}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'above'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="h7" x={currentX} y={currentY} radius={radius} color={dark}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'upperLeft'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="g8" x={currentX} y={currentY} radius={radius} color={light}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'upperLeft'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="f9" x={currentX} y={currentY} radius={radius} color={grey}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="e8" x={currentX} y={currentY} radius={radius} color={light}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="d7" x={currentX} y={currentY} radius={radius} color={dark}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomLeft'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="c6" x={currentX} y={currentY} radius={radius} color={grey}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="c5" x={currentX} y={currentY} radius={radius} color={dark}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="c4" x={currentX} y={currentY} radius={radius} color={light}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'below'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="c3" x={currentX} y={currentY} radius={radius} color={grey}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="d3" x={currentX} y={currentY} radius={radius} color={light}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="e3" x={currentX} y={currentY} radius={radius} color={dark}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'bottomRight'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="f3" x={currentX} y={currentY} radius={radius} color={grey}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="g3" x={currentX} y={currentY} radius={radius} color={dark}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="h3" x={currentX} y={currentY} radius={radius} color={light}/>);

    newCenter = calculateNewCenter(currentX, currentY, radius, 'upperRight'); currentX = newCenter.x; currentY = newCenter.y;
    hexagons.push(<Hexagon key="i3" x={currentX} y={currentY} radius={radius} color={grey}/>);

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

    return hexagons;
  }

  const hexagons = generateHexTiles(width / 2, height / 2, radius);

  const pieces = hexagons.map((hexTile) => {
    const pieceData = gameBoard.boardState[hexTile.key];
    if (pieceData) {
      return (
        <Piece 
          key={`piece-${hexTile.key}`} 
          x={hexTile.props.x} 
          y={hexTile.props.y} 
          radius={radius} 
          type={pieceData.type} 
          color={pieceData.color} 
        />
      );
    }
    return null;
  });

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
