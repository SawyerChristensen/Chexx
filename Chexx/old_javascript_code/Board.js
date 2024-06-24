import React, { useRef, useState, useEffect } from 'react';
import { Dimensions, View, StyleSheet } from 'react-native';
import Background, { hexTiles } from './Background';
import HexChessGame from './GameEngine';
import Piece from './Piece';
import { splitKey } from './UtilityFunctions';

const { width, height } = Dimensions.get('window');

const styles = StyleSheet.create({
  container: {
    width,
    height,
  }
})

const hexChess = new HexChessGame(); //can export this to an app file or something, maybe load a game instead of creating a new one

const Board = () => {
  //console.log("Initial boardState:", hexChess.boardState);

  const [state, setState] = useState({
    player: "white",
    board: hexChess.boardState,
  });

  /*
  const onTurn = useCallback(() => {
    setState({
      player: state.player === "white" ? "black" : "white",
      board: hexChess.boardState,
    });
  }, [hexChess, state.player]);
  */

  return (
    <View style={styles.container}>
      <Background/>
      {/*console.log('Updated game state:', state.board)*/}
      {
        React.Children.map(hexTiles, hex => {
          const { columnLetter, rowIndex } = splitKey(hex.key);
          const pieceData = state.board[columnLetter][rowIndex]; //board is a 0 start array, the board isnt
          //console.log(columnLetter, rowIndex, pieceData);
          if (pieceData) {
            const uniqueKey = `${columnLetter}-${rowIndex}-${pieceData.color}-${pieceData.type}`;
            return (
              <Piece
                key={uniqueKey}
                column={columnLetter}
                row={rowIndex}
                color={pieceData.color} 
                type={pieceData.type}
                startingX={hex.props.x}
                startingY={hex.props.y}
                gameInstance={hexChess}
                setBoardState={setState}
              />
            )
          }
          return null;
        })
      }
    </View>
  );
};

export default Board;
