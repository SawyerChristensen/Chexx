class HexChessGame {
    constructor() {
      this.boardState = this.initializeBoard();
      this.gameStatus = 'ongoing';
      this.player = 'white';
      // ... any other initializations
    }
  
    initializeBoard() {
        const board = {
            'a': Array(6).fill({color: null, type: null}),
            'b': Array(7).fill({color: null, type: null}),
            'c': Array(8).fill({color: null, type: null}),
            'd': Array(9).fill({color: null, type: null}),
            'e': Array(10).fill({color: null, type: null}),
            'f': Array(11).fill({color: null, type: null}),
            'g': Array(10).fill({color: null, type: null}),
            'h': Array(9).fill({color: null, type: null}),
            'i': Array(8).fill({color: null, type: null}),
            'k': Array(7).fill({color: null, type: null}),
            'l': Array(6).fill({color: null, type: null}),
        }

        board['b'][6] = {color: "black", type: "pawn", hasMoved: false};
        board['c'][6] = {color: "black", type: "pawn", hasMoved: false};
        board['d'][6] = {color: "black", type: "pawn", hasMoved: false};
        board['e'][6] = {color: "black", type: "pawn", hasMoved: false};
        board['f'][6] = {color: "black", type: "pawn", hasMoved: false};
        board['g'][6] = {color: "black", type: "pawn", hasMoved: false};
        board['h'][6] = {color: "black", type: "pawn", hasMoved: false};
        board['i'][6] = {color: "black", type: "pawn", hasMoved: false};
        board['k'][6] = {color: "black", type: "pawn", hasMoved: false};
        board['b'][0] = {color: "white", type: "pawn", hasMoved: false};
        board['c'][1] = {color: "white", type: "pawn", hasMoved: false};
        board['d'][2] = {color: "white", type: "pawn", hasMoved: false};
        board['e'][3] = {color: "white", type: "pawn", hasMoved: false};
        board['f'][4] = {color: "white", type: "pawn", hasMoved: false};
        board['g'][3] = {color: "white", type: "pawn", hasMoved: false};
        board['h'][2] = {color: "white", type: "pawn", hasMoved: false};
        board['i'][1] = {color: "white", type: "pawn", hasMoved: false};
        board['k'][0] = {color: "white", type: "pawn", hasMoved: false};
        board['c'][7] = {color: "black", type: "rook", hasMoved: false};
        board['c'][0] = {color: "white", type: "rook", hasMoved: false};
        board['d'][8] = {color: "black", type: "knight", hasMoved: false};
        board['d'][0] = {color: "white", type: "knight", hasMoved: false};
        board['e'][9] = {color: "black", type: "queen", hasMoved: false};
        board['e'][0] = {color: "white", type: "queen", hasMoved: false};
        board['f'][10]= {color: "black", type: "bishop", hasMoved: false};
        board['f'][9] = {color: "black", type: "bishop", hasMoved: false};
        board['f'][8] = {color: "black", type: "bishop", hasMoved: false};
        board['f'][0] = {color: "white", type: "bishop", hasMoved: false};
        board['f'][1] = {color: "white", type: "bishop", hasMoved: false};
        board['f'][2] = {color: "white", type: "bishop", hasMoved: false};
        board['g'][9] = {color: "black", type: "king", hasMoved: false};
        board['g'][0] = {color: "white", type: "king", hasMoved: false};
        board['h'][8] = {color: "black", type: "knight", hasMoved: false};
        board['h'][0] = {color: "white", type: "knight", hasMoved: false};
        board['i'][7] = {color: "black", type: "rook", hasMoved: false};
        board['i'][0] = {color: "white", type: "rook", hasMoved: false};
        

        return board;
    }

    switchPlayer() {
        if (this.player === "white"){
            this.player = "black";
        }
        if (this.player === "black") {
            this.player = "white";
        }
        else {
            console.log("game must have ended!") //make player "none" when game ends
        }
    }

    isValidPosition(column, row) { //returns if (column, row) is an actual tile
        if (!this.boardState.hasOwnProperty(column) || row >= this.boardState[column].length || row < 0) {
            return false;
        }
        return true
    }

    validMoveList(piece, startingColumn, startingRow) { //returns array of valid positions to move to

        const columns = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'k', 'l'];
        const colIndex = columns.indexOf(startingColumn);
        //console.log(this.boardState);

        const valid_moves = [];
        /*if (piece.color !== this.player) { ************UNCOMMENT WHEN TURN CHANGE IS IMPLEMENTED**************
              // maybe alert some system prompt of "not your turn!"
        //    return valid_moves;
        }*/

        if (piece.color === "white" && piece.type === "pawn") {
            // move up 1
            if ((this.isValidPosition(startingColumn, startingRow + 1)) && (this.boardState[startingColumn][startingRow + 1].type === null)){
                valid_moves.push([startingColumn, startingRow + 1]);
                //if it hasnt moved at all, bonus move!
                if ((this.boardState[startingColumn][startingRow].hasMoved === false) && (this.boardState[startingColumn][startingRow + 2].type === null)){
                    valid_moves.push([startingColumn, startingRow + 2]);
                }
            }
            // left side of board
            if (colIndex < 5) {
                if (this.isValidPosition(columns[colIndex - 1], startingRow)){ //capture left
                    if (this.boardState[columns[colIndex - 1]][startingRow].color === "black"){
                        valid_moves.push([columns[colIndex - 1], startingRow]);
                    }
                }
                if (this.isValidPosition(columns[colIndex + 1], startingRow + 1)){ //capture right
                    if (this.boardState[columns[colIndex + 1]][startingRow + 1].color === "black"){
                        valid_moves.push([columns[colIndex + 1], startingRow + 1]);
                    }
                }
            }
            // center of board
            if (colIndex == 5) {
                if (this.isValidPosition(columns[colIndex - 1], startingRow)){ //capture left
                    if (this.boardState[columns[colIndex - 1]][startingRow].color === "black"){
                        valid_moves.push([columns[colIndex - 1], startingRow]);
                    }
                }
                if (this.isValidPosition(columns[colIndex + 1], startingRow)){ //capture right
                    if (this.boardState[columns[colIndex + 1]][startingRow].color === "black"){
                        valid_moves.push([columns[colIndex + 1], startingRow]);
                    }
                }
            }
            // right of board
            if (colIndex > 5) {
                if (this.isValidPosition(columns[colIndex - 1], startingRow + 1)){ //capture left
                    if (this.boardState[columns[colIndex - 1]][startingRow + 1].color === "black"){
                        valid_moves.push([columns[colIndex - 1], startingRow + 1]);
                    }
                }
                if (this.isValidPosition(columns[colIndex + 1], startingRow)){ //capture right
                    if (this.boardState[columns[colIndex + 1]][startingRow].color === "black"){
                        valid_moves.push([columns[colIndex + 1], startingRow]);
                    }
                }
            }
            return valid_moves;
        }

        if (piece.color === "black" && piece.type === "pawn") {
            // move down 1
            if ((this.isValidPosition(startingColumn, startingRow - 1)) && (this.boardState[startingColumn][startingRow - 1].type === null)){
                valid_moves.push([startingColumn, startingRow - 1]);
                //if it hasnt moved at all, bonus move!
                if ((this.boardState[startingColumn][startingRow].hasMoved === false) && (this.boardState[startingColumn][startingRow - 2].type === null)){
                    valid_moves.push([startingColumn, startingRow - 2]);
                }
            }
            // left side of board
            if (colIndex < 5) {
                if (this.isValidPosition(columns[colIndex - 1], startingRow - 1)){ //capture left
                    if (this.boardState[columns[colIndex - 1]][startingRow - 1].color === "white"){
                        valid_moves.push([columns[colIndex - 1], startingRow - 1]);
                    }
                }
                if (this.isValidPosition(columns[colIndex + 1], startingRow)){ //capture right
                    if (this.boardState[columns[colIndex + 1]][startingRow].color === "white"){
                        valid_moves.push([columns[colIndex + 1], startingRow]);
                    }
                }
            }
            // center of board
            if (colIndex == 5) {
                if (this.isValidPosition(columns[colIndex - 1], startingRow - 1)){ //capture left
                    if (this.boardState[columns[colIndex - 1]][startingRow - 1].color === "white"){
                        valid_moves.push([columns[colIndex - 1], startingRow - 1]);
                    }
                }
                if (this.isValidPosition(columns[colIndex + 1], startingRow - 1)){ //capture right
                    if (this.boardState[columns[colIndex + 1]][startingRow - 1].color === "white"){
                        valid_moves.push([columns[colIndex + 1], startingRow - 1]);
                    }
                }
            }
            // right of board
            if (colIndex > 5) {
                if (this.isValidPosition(columns[colIndex - 1], startingRow)){ //capture left
                    if (this.boardState[columns[colIndex - 1]][startingRow].color === "white"){
                        valid_moves.push([columns[colIndex - 1], startingRow]);
                    }
                }
                if (this.isValidPosition(columns[colIndex + 1], startingRow - 1)){ //capture right
                    if (this.boardState[columns[colIndex + 1]][startingRow - 1].color === "white"){
                        valid_moves.push([columns[colIndex + 1], startingRow - 1]);
                    }
                }
            }
            return valid_moves;
        }

        if (piece.color === "white" && piece.type === "rook") {

            //moving UP ***
            let updown_counter = 1;
            while (this.isValidPosition(startingColumn, startingRow + updown_counter)) {

                if (this.boardState[startingColumn][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([startingColumn, startingRow + updown_counter]);
                }
                if (this.boardState[startingColumn][startingRow + updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[startingColumn][startingRow + updown_counter].color === "black") { //capturing a black piece
                    valid_moves.push([startingColumn, startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }

            //moving DOWN ***
            updown_counter = 1;
            while (this.isValidPosition(startingColumn, startingRow - updown_counter)) {

                if ((this.boardState[startingColumn][startingRow - updown_counter]).type === null) { //moving down
                    valid_moves.push([startingColumn, startingRow - updown_counter]);
                }
                if (this.boardState[startingColumn][startingRow - updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[startingColumn][startingRow - updown_counter].color === "black") { //capturing a black piece
                    valid_moves.push([startingColumn, startingRow - updown_counter]);
                    break;
                }
                updown_counter++;
            }

            //moving UP LEFT ***
            updown_counter = 1;
                //on the right side of the board
            while (colIndex - updown_counter >= 5 && this.isValidPosition(columns[colIndex - updown_counter], startingRow + updown_counter)) {//could maybe get rid of the is valid position check here

                if (this.boardState[columns[colIndex - updown_counter]][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], startingRow + updown_counter]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow + updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow + updown_counter].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex - updown_counter], startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }
            let new_starting_row = startingRow + updown_counter - 1;
                //on the middle/left side of the board
            while (colIndex - updown_counter < 5 && this.isValidPosition(columns[colIndex - updown_counter], new_starting_row)) {

                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row]);
                    break;
                }
                updown_counter++;
            }

            //moving UP RIGHT ***
            updown_counter = 1;
                //on the left side of the board
            while (colIndex + updown_counter <= 5 && this.isValidPosition(columns[colIndex + updown_counter], startingRow + updown_counter)) {//could maybe get rid of the is valid position check here

                if (this.boardState[columns[colIndex + updown_counter]][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], startingRow + updown_counter]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow + updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow + updown_counter].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex + updown_counter], startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/right side of the board
            while (colIndex + updown_counter > 5 && this.isValidPosition(columns[colIndex + updown_counter], new_starting_row)) {

                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row]);
                    break;
                }
                updown_counter++;
            }

            //moving DOWN LEFT ***
            updown_counter = 1;
                //on the right side of the board
            while (colIndex - updown_counter >= 5 && this.isValidPosition(columns[colIndex - updown_counter], startingRow)) {//could maybe get rid of the is valid position check here

                if (this.boardState[columns[colIndex - updown_counter]][startingRow].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], startingRow]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex - updown_counter], startingRow]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/left side of the board
            while (colIndex - updown_counter < 5 && this.isValidPosition(columns[colIndex - updown_counter], new_starting_row - updown_counter)) {

                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row - updown_counter]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - updown_counter].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row - updown_counter]);
                    break;
                }
                updown_counter++;
            }

            //moving DOWN RIGHT ***
            updown_counter = 1;
                //on the left side of the board
            while (colIndex + updown_counter <= 5 && this.isValidPosition(columns[colIndex + updown_counter], startingRow)) {//could maybe get rid of the is valid position check here

                if (this.boardState[columns[colIndex + updown_counter]][startingRow].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], startingRow]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex + updown_counter], startingRow]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/right side of the board
            while (colIndex + updown_counter > 5 && this.isValidPosition(columns[colIndex + updown_counter], new_starting_row - updown_counter)) {

                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row - updown_counter]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - updown_counter].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row - updown_counter]);
                    break;
                }
                updown_counter++;
            }


            return valid_moves;
        }

        if (piece.color === "black" && piece.type === "rook") {

            //moving UP ***
            let updown_counter = 1;
            while (this.isValidPosition(startingColumn, startingRow + updown_counter)) {

                if (this.boardState[startingColumn][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([startingColumn, startingRow + updown_counter]);
                }
                if (this.boardState[startingColumn][startingRow + updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[startingColumn][startingRow + updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([startingColumn, startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }

            //moving DOWN ***
            updown_counter = 1;
            while (this.isValidPosition(startingColumn, startingRow - updown_counter)) {

                if ((this.boardState[startingColumn][startingRow - updown_counter]).type === null) { //moving down
                    valid_moves.push([startingColumn, startingRow - updown_counter]);
                }
                if (this.boardState[startingColumn][startingRow - updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[startingColumn][startingRow - updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([startingColumn, startingRow - updown_counter]);
                    break;
                }
                updown_counter++;
            }

            //moving UP LEFT ***
            updown_counter = 1;
                //on the right side of the board
            while (colIndex - updown_counter >= 5 && this.isValidPosition(columns[colIndex - updown_counter], startingRow + updown_counter)) {//could maybe get rid of the is valid position check here

                if (this.boardState[columns[colIndex - updown_counter]][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], startingRow + updown_counter]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow + updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow + updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }
            let new_starting_row = startingRow + updown_counter - 1;
                //on the middle/left side of the board
            while (colIndex - updown_counter < 5 && this.isValidPosition(columns[colIndex - updown_counter], new_starting_row)) {

                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row]);
                    break;
                }
                updown_counter++;
            }

            //moving UP RIGHT ***
            updown_counter = 1;
                //on the left side of the board
            while (colIndex + updown_counter <= 5 && this.isValidPosition(columns[colIndex + updown_counter], startingRow + updown_counter)) {//could maybe get rid of the is valid position check here

                if (this.boardState[columns[colIndex + updown_counter]][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], startingRow + updown_counter]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow + updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow + updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex + updown_counter], startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/right side of the board
            while (colIndex + updown_counter > 5 && this.isValidPosition(columns[colIndex + updown_counter], new_starting_row)) {

                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row]);
                    break;
                }
                updown_counter++;
            }

            //moving DOWN LEFT ***
            updown_counter = 1;
                //on the right side of the board
            while (colIndex - updown_counter >= 5 && this.isValidPosition(columns[colIndex - updown_counter], startingRow)) {//could maybe get rid of the is valid position check here

                if (this.boardState[columns[colIndex - updown_counter]][startingRow].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], startingRow]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], startingRow]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/left side of the board
            while (colIndex - updown_counter < 5 && this.isValidPosition(columns[colIndex - updown_counter], new_starting_row - updown_counter)) {

                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row - updown_counter]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row - updown_counter]);
                    break;
                }
                updown_counter++;
            }

            //moving DOWN RIGHT ***
            updown_counter = 1;
                //on the left side of the board
            while (colIndex + updown_counter <= 5 && this.isValidPosition(columns[colIndex + updown_counter], startingRow)) {//could maybe get rid of the is valid position check here

                if (this.boardState[columns[colIndex + updown_counter]][startingRow].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], startingRow]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex + updown_counter], startingRow]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/right side of the board
            while (colIndex + updown_counter > 5 && this.isValidPosition(columns[colIndex + updown_counter], new_starting_row - updown_counter)) {

                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row - updown_counter]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row - updown_counter]);
                    break;
                }
                updown_counter++;
            }


            return valid_moves;
        }

        if (piece.color === "white" && piece.type === "bishop") {

        //moving UP LEFT DIAGONAL ***
            updown_counter = 1;
                //on the right side of the board
            while (colIndex - updown_counter >= 5 && this.isValidPosition(columns[colIndex - updown_counter], startingRow + (updown_counter * 2))) {

                if (this.boardState[columns[colIndex - updown_counter]][startingRow + (updown_counter * 2)].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], startingRow + (updown_counter * 2)]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow + (updown_counter * 2)].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow + (updown_counter * 2)].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], startingRow + (updown_counter * 2)]);
                    break;
                }
                updown_counter++;
            }
            let new_starting_row = startingRow + updown_counter - 1;
                //on the middle/left side of the board
            while (colIndex - updown_counter < 5 && this.isValidPosition(columns[colIndex - updown_counter], new_starting_row + updown_counter)) {

                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row + updown_counter]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row + updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row + updown_counter].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row + updown_counter]);
                    break;
                }
                updown_counter++;
            }

        //moving UP RIGHT DIAGONAL ***
            updown_counter = 1;
                //on the left side of the board
            while (colIndex + updown_counter <= 5 && this.isValidPosition(columns[colIndex + updown_counter], startingRow + (updown_counter * 2))) {

                if (this.boardState[columns[colIndex + updown_counter]][startingRow + (updown_counter * 2)].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], startingRow + (updown_counter * 2)]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow + (updown_counter * 2)].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow + (updown_counter * 2)].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex + updown_counter], startingRow + (updown_counter * 2)]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/right side of the board
            while (colIndex + updown_counter > 5 && this.isValidPosition(columns[colIndex + updown_counter], new_starting_row + updown_counter)) {

                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row + updown_counter]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row + updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row + updown_counter].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row + updown_counter]);
                    break;
                }
                updown_counter++;
            }

        //moving DOWN LEFT DIAGONAL ***
            updown_counter = 1;
                //on the right side of the board
            while (colIndex - updown_counter >= 5 && this.isValidPosition(columns[colIndex - updown_counter], startingRow  - updown_counter)) {

                if (this.boardState[columns[colIndex - updown_counter]][startingRow  - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], startingRow  - updown_counter]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow  - updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow  - updown_counter].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], startingRow  - updown_counter]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/left side of the board
            while (colIndex - updown_counter < 5 && this.isValidPosition(columns[colIndex - updown_counter], new_starting_row - (updown_counter * 2))) {

                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - (updown_counter * 2)].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row - (updown_counter * 2)]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - (updown_counter * 2)].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - (updown_counter * 2)].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row - (updown_counter * 2)]);
                    break;
                }
                updown_counter++;
            }

        //moving DOWN RIGHT DIAGONAL ***
            updown_counter = 1;
                //on the left side of the board
            while (colIndex + updown_counter <= 5 && this.isValidPosition(columns[colIndex + updown_counter], startingRow - updown_counter)) {

                if (this.boardState[columns[colIndex + updown_counter]][startingRow - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], startingRow - updown_counter]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow - updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow - updown_counter].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex + updown_counter], startingRow - updown_counter]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/right side of the board
            while (colIndex + updown_counter > 5 && this.isValidPosition(columns[colIndex + updown_counter], new_starting_row - (updown_counter * 2))) {

                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - (updown_counter * 2)].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row - (updown_counter * 2)]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - (updown_counter * 2)].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - (updown_counter * 2)].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row - (updown_counter * 2)]);
                    break;
                }
                updown_counter++;
            }

        //moving PERFECT LEFT ***
            updown_counter = 1;
                //on the right side of the board
            while (colIndex - (updown_counter * 2) > 4 && this.isValidPosition(columns[colIndex - (updown_counter * 2)], startingRow + updown_counter)) {

                if (this.boardState[columns[colIndex - (updown_counter * 2)]][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], startingRow + updown_counter]);
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][startingRow + updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][startingRow + updown_counter].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //crossing the middle column
            while (colIndex - (updown_counter * 2) == 4 && this.isValidPosition(columns[colIndex - (updown_counter * 2)], new_starting_row)) {

                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row].color === null) { //moving up
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], new_starting_row]);
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], new_starting_row]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = new_starting_row + updown_counter - 1;
                //on the left side of the board
            while (colIndex - (updown_counter * 2) < 4 && this.isValidPosition(columns[colIndex - (updown_counter * 2)], new_starting_row - updown_counter)) {

                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], new_starting_row - updown_counter]);
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row - updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row - updown_counter].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], new_starting_row - updown_counter]);
                    break;
                }
                updown_counter++;
            }

        //moving PERFECT RIGHT ***
            updown_counter = 1;
                //on the left side of the board
            while (colIndex + (updown_counter * 2) < 6 && this.isValidPosition(columns[colIndex + (updown_counter * 2)], startingRow + updown_counter)) {

                if (this.boardState[columns[colIndex + (updown_counter * 2)]][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], startingRow + updown_counter]);
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][startingRow + updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][startingRow + updown_counter].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //crossing the middle column
            while (colIndex + (updown_counter * 2) == 6 && this.isValidPosition(columns[colIndex + (updown_counter * 2)], new_starting_row)) {

                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row].color === null) { //moving up
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], new_starting_row]);
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], new_starting_row]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = new_starting_row + updown_counter - 1;
                //on the right side of the board
            while (colIndex + (updown_counter * 2) > 6 && this.isValidPosition(columns[colIndex + (updown_counter * 2)], new_starting_row - updown_counter)) {

                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], new_starting_row - updown_counter]);
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row - updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row - updown_counter].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], new_starting_row - updown_counter]);
                    break;
                }
                updown_counter++;
            }

            return valid_moves;
        }

        if (piece.color === "black" && piece.type === "bishop") {

            //moving UP LEFT DIAGONAL ***
                updown_counter = 1;
                    //on the right side of the board
                while (colIndex - updown_counter >= 5 && this.isValidPosition(columns[colIndex - updown_counter], startingRow + (updown_counter * 2))) {
    
                    if (this.boardState[columns[colIndex - updown_counter]][startingRow + (updown_counter * 2)].color === null) { //moving up
                        valid_moves.push([columns[colIndex - updown_counter], startingRow + (updown_counter * 2)]);
                    }
                    if (this.boardState[columns[colIndex - updown_counter]][startingRow + (updown_counter * 2)].color === "black") { //hitting your own piece
                        break;
                    }
                    if (this.boardState[columns[colIndex - updown_counter]][startingRow + (updown_counter * 2)].color === "white") { //capturing a piece
                        valid_moves.push([columns[colIndex - updown_counter], startingRow + (updown_counter * 2)]);
                        break;
                    }
                    updown_counter++;
                }
                let new_starting_row = startingRow + updown_counter - 1;
                    //on the middle/left side of the board
                while (colIndex - updown_counter < 5 && this.isValidPosition(columns[colIndex - updown_counter], new_starting_row + updown_counter)) {
    
                    if (this.boardState[columns[colIndex - updown_counter]][new_starting_row + updown_counter].color === null) { //moving up
                        valid_moves.push([columns[colIndex - updown_counter], new_starting_row + updown_counter]);
                    }
                    if (this.boardState[columns[colIndex - updown_counter]][new_starting_row + updown_counter].color === "black") { //hitting your own piece
                        break;
                    }
                    if (this.boardState[columns[colIndex - updown_counter]][new_starting_row + updown_counter].color === "white") { //capturing a piece
                        valid_moves.push([columns[colIndex - updown_counter], new_starting_row + updown_counter]);
                        break;
                    }
                    updown_counter++;
                }
    
            //moving UP RIGHT DIAGONAL ***
                updown_counter = 1;
                    //on the left side of the board
                while (colIndex + updown_counter <= 5 && this.isValidPosition(columns[colIndex + updown_counter], startingRow + (updown_counter * 2))) {
    
                    if (this.boardState[columns[colIndex + updown_counter]][startingRow + (updown_counter * 2)].color === null) { //moving up
                        valid_moves.push([columns[colIndex + updown_counter], startingRow + (updown_counter * 2)]);
                    }
                    if (this.boardState[columns[colIndex + updown_counter]][startingRow + (updown_counter * 2)].color === "black") { //hitting your own piece
                        break;
                    }
                    if (this.boardState[columns[colIndex + updown_counter]][startingRow + (updown_counter * 2)].color === "white") { //capturing a piece
                        valid_moves.push([columns[colIndex + updown_counter], startingRow + (updown_counter * 2)]);
                        break;
                    }
                    updown_counter++;
                }
                new_starting_row = startingRow + updown_counter - 1;
                    //on the middle/right side of the board
                while (colIndex + updown_counter > 5 && this.isValidPosition(columns[colIndex + updown_counter], new_starting_row + updown_counter)) {
    
                    if (this.boardState[columns[colIndex + updown_counter]][new_starting_row + updown_counter].color === null) { //moving up
                        valid_moves.push([columns[colIndex + updown_counter], new_starting_row + updown_counter]);
                    }
                    if (this.boardState[columns[colIndex + updown_counter]][new_starting_row + updown_counter].color === "black") { //hitting your own piece
                        break;
                    }
                    if (this.boardState[columns[colIndex + updown_counter]][new_starting_row + updown_counter].color === "white") { //capturing a piece
                        valid_moves.push([columns[colIndex + updown_counter], new_starting_row + updown_counter]);
                        break;
                    }
                    updown_counter++;
                }
    
            //moving DOWN LEFT DIAGONAL ***
                updown_counter = 1;
                    //on the right side of the board
                while (colIndex - updown_counter >= 5 && this.isValidPosition(columns[colIndex - updown_counter], startingRow  - updown_counter)) {
    
                    if (this.boardState[columns[colIndex - updown_counter]][startingRow  - updown_counter].color === null) { //moving up
                        valid_moves.push([columns[colIndex - updown_counter], startingRow  - updown_counter]);
                    }
                    if (this.boardState[columns[colIndex - updown_counter]][startingRow  - updown_counter].color === "black") { //hitting your own piece
                        break;
                    }
                    if (this.boardState[columns[colIndex - updown_counter]][startingRow  - updown_counter].color === "white") { //capturing a piece
                        valid_moves.push([columns[colIndex - updown_counter], startingRow  - updown_counter]);
                        break;
                    }
                    updown_counter++;
                }
                new_starting_row = startingRow + updown_counter - 1;
                    //on the middle/left side of the board
                while (colIndex - updown_counter < 5 && this.isValidPosition(columns[colIndex - updown_counter], new_starting_row - (updown_counter * 2))) {
    
                    if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - (updown_counter * 2)].color === null) { //moving up
                        valid_moves.push([columns[colIndex - updown_counter], new_starting_row - (updown_counter * 2)]);
                    }
                    if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - (updown_counter * 2)].color === "black") { //hitting your own piece
                        break;
                    }
                    if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - (updown_counter * 2)].color === "white") { //capturing a piece
                        valid_moves.push([columns[colIndex - updown_counter], new_starting_row - (updown_counter * 2)]);
                        break;
                    }
                    updown_counter++;
                }
    
            //moving DOWN RIGHT DIAGONAL ***
                updown_counter = 1;
                    //on the left side of the board
                while (colIndex + updown_counter <= 5 && this.isValidPosition(columns[colIndex + updown_counter], startingRow - updown_counter)) {
    
                    if (this.boardState[columns[colIndex + updown_counter]][startingRow - updown_counter].color === null) { //moving up
                        valid_moves.push([columns[colIndex + updown_counter], startingRow - updown_counter]);
                    }
                    if (this.boardState[columns[colIndex + updown_counter]][startingRow - updown_counter].color === "black") { //hitting your own piece
                        break;
                    }
                    if (this.boardState[columns[colIndex + updown_counter]][startingRow - updown_counter].color === "white") { //capturing a black piece
                        valid_moves.push([columns[colIndex + updown_counter], startingRow - updown_counter]);
                        break;
                    }
                    updown_counter++;
                }
                new_starting_row = startingRow + updown_counter - 1;
                    //on the middle/right side of the board
                while (colIndex + updown_counter > 5 && this.isValidPosition(columns[colIndex + updown_counter], new_starting_row - (updown_counter * 2))) {
    
                    if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - (updown_counter * 2)].color === null) { //moving up
                        valid_moves.push([columns[colIndex + updown_counter], new_starting_row - (updown_counter * 2)]);
                    }
                    if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - (updown_counter * 2)].color === "black") { //hitting your own piece
                        break;
                    }
                    if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - (updown_counter * 2)].color === "white") { //capturing a black piece
                        valid_moves.push([columns[colIndex + updown_counter], new_starting_row - (updown_counter * 2)]);
                        break;
                    }
                    updown_counter++;
                }
    
            //moving PERFECT LEFT ***
                updown_counter = 1;
                    //on the right side of the board
                while (colIndex - (updown_counter * 2) > 4 && this.isValidPosition(columns[colIndex - (updown_counter * 2)], startingRow + updown_counter)) {
    
                    if (this.boardState[columns[colIndex - (updown_counter * 2)]][startingRow + updown_counter].color === null) { //moving up
                        valid_moves.push([columns[colIndex - (updown_counter * 2)], startingRow + updown_counter]);
                    }
                    if (this.boardState[columns[colIndex - (updown_counter * 2)]][startingRow + updown_counter].color === "black") { //hitting your own piece
                        break;
                    }
                    if (this.boardState[columns[colIndex - (updown_counter * 2)]][startingRow + updown_counter].color === "white") { //capturing a piece
                        valid_moves.push([columns[colIndex - (updown_counter * 2)], startingRow + updown_counter]);
                        break;
                    }
                    updown_counter++;
                }
                new_starting_row = startingRow + updown_counter - 1;
                    //crossing the middle column
                while (colIndex - (updown_counter * 2) == 4 && this.isValidPosition(columns[colIndex - (updown_counter * 2)], new_starting_row)) {
    
                    if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row].color === null) { //moving up
                        valid_moves.push([columns[colIndex - (updown_counter * 2)], new_starting_row]);
                    }
                    if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row].color === "black") { //hitting your own piece
                        break;
                    }
                    if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row].color === "white") { //capturing a piece
                        valid_moves.push([columns[colIndex - (updown_counter * 2)], new_starting_row]);
                        break;
                    }
                    updown_counter++;
                }
                new_starting_row = new_starting_row + updown_counter - 1;
                    //on the left side of the board
                while (colIndex - (updown_counter * 2) < 4 && this.isValidPosition(columns[colIndex - (updown_counter * 2)], new_starting_row - updown_counter)) {
    
                    if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row - updown_counter].color === null) { //moving up
                        valid_moves.push([columns[colIndex - (updown_counter * 2)], new_starting_row - updown_counter]);
                    }
                    if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row - updown_counter].color === "black") { //hitting your own piece
                        break;
                    }
                    if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row - updown_counter].color === "white") { //capturing a piece
                        valid_moves.push([columns[colIndex - (updown_counter * 2)], new_starting_row - updown_counter]);
                        break;
                    }
                    updown_counter++;
                }
    
            //moving PERFECT RIGHT ***
                updown_counter = 1;
                    //on the left side of the board
                while (colIndex + (updown_counter * 2) < 6 && this.isValidPosition(columns[colIndex + (updown_counter * 2)], startingRow + updown_counter)) {
    
                    if (this.boardState[columns[colIndex + (updown_counter * 2)]][startingRow + updown_counter].color === null) { //moving up
                        valid_moves.push([columns[colIndex + (updown_counter * 2)], startingRow + updown_counter]);
                    }
                    if (this.boardState[columns[colIndex + (updown_counter * 2)]][startingRow + updown_counter].color === "black") { //hitting your own piece
                        break;
                    }
                    if (this.boardState[columns[colIndex + (updown_counter * 2)]][startingRow + updown_counter].color === "white") { //capturing a piece
                        valid_moves.push([columns[colIndex + (updown_counter * 2)], startingRow + updown_counter]);
                        break;
                    }
                    updown_counter++;
                }
                new_starting_row = startingRow + updown_counter - 1;
                    //crossing the middle column
                while (colIndex + (updown_counter * 2) == 6 && this.isValidPosition(columns[colIndex + (updown_counter * 2)], new_starting_row)) {
    
                    if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row].color === null) { //moving up
                        valid_moves.push([columns[colIndex + (updown_counter * 2)], new_starting_row]);
                    }
                    if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row].color === "black") { //hitting your own piece
                        break;
                    }
                    if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row].color === "white") { //capturing a piece
                        valid_moves.push([columns[colIndex + (updown_counter * 2)], new_starting_row]);
                        break;
                    }
                    updown_counter++;
                }
                new_starting_row = new_starting_row + updown_counter - 1;
                    //on the right side of the board
                while (colIndex + (updown_counter * 2) > 6 && this.isValidPosition(columns[colIndex + (updown_counter * 2)], new_starting_row - updown_counter)) {
    
                    if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row - updown_counter].color === null) { //moving up
                        valid_moves.push([columns[colIndex + (updown_counter * 2)], new_starting_row - updown_counter]);
                    }
                    if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row - updown_counter].color === "black") { //hitting your own piece
                        break;
                    }
                    if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row - updown_counter].color === "white") { //capturing a piece
                        valid_moves.push([columns[colIndex + (updown_counter * 2)], new_starting_row - updown_counter]);
                        break;
                    }
                    updown_counter++;
                }
    
                return valid_moves;
        }

        if (piece.color === "white" && piece.type === "queen") {

            //moving UP ***
            let updown_counter = 1;
            while (this.isValidPosition(startingColumn, startingRow + updown_counter)) {

                if (this.boardState[startingColumn][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([startingColumn, startingRow + updown_counter]);
                }
                if (this.boardState[startingColumn][startingRow + updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[startingColumn][startingRow + updown_counter].color === "black") { //capturing a black piece
                    valid_moves.push([startingColumn, startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }

            //moving DOWN ***
            updown_counter = 1;
            while (this.isValidPosition(startingColumn, startingRow - updown_counter)) {

                if ((this.boardState[startingColumn][startingRow - updown_counter]).type === null) { //moving down
                    valid_moves.push([startingColumn, startingRow - updown_counter]);
                }
                if (this.boardState[startingColumn][startingRow - updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[startingColumn][startingRow - updown_counter].color === "black") { //capturing a black piece
                    valid_moves.push([startingColumn, startingRow - updown_counter]);
                    break;
                }
                updown_counter++;
            }

            //moving UP LEFT ***
            updown_counter = 1;
                //on the right side of the board
            while (colIndex - updown_counter >= 5 && this.isValidPosition(columns[colIndex - updown_counter], startingRow + updown_counter)) {//could maybe get rid of the is valid position check here

                if (this.boardState[columns[colIndex - updown_counter]][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], startingRow + updown_counter]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow + updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow + updown_counter].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex - updown_counter], startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }
            let new_starting_row = startingRow + updown_counter - 1;
                //on the middle/left side of the board
            while (colIndex - updown_counter < 5 && this.isValidPosition(columns[colIndex - updown_counter], new_starting_row)) {

                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row]);
                    break;
                }
                updown_counter++;
            }

            //moving UP RIGHT ***
            updown_counter = 1;
                //on the left side of the board
            while (colIndex + updown_counter <= 5 && this.isValidPosition(columns[colIndex + updown_counter], startingRow + updown_counter)) {//could maybe get rid of the is valid position check here

                if (this.boardState[columns[colIndex + updown_counter]][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], startingRow + updown_counter]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow + updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow + updown_counter].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex + updown_counter], startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/right side of the board
            while (colIndex + updown_counter > 5 && this.isValidPosition(columns[colIndex + updown_counter], new_starting_row)) {

                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row]);
                    break;
                }
                updown_counter++;
            }

            //moving DOWN LEFT ***
            updown_counter = 1;
                //on the right side of the board
            while (colIndex - updown_counter >= 5 && this.isValidPosition(columns[colIndex - updown_counter], startingRow)) {//could maybe get rid of the is valid position check here

                if (this.boardState[columns[colIndex - updown_counter]][startingRow].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], startingRow]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex - updown_counter], startingRow]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/left side of the board
            while (colIndex - updown_counter < 5 && this.isValidPosition(columns[colIndex - updown_counter], new_starting_row - updown_counter)) {

                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row - updown_counter]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - updown_counter].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row - updown_counter]);
                    break;
                }
                updown_counter++;
            }

            //moving DOWN RIGHT ***
            updown_counter = 1;
                //on the left side of the board
            while (colIndex + updown_counter <= 5 && this.isValidPosition(columns[colIndex + updown_counter], startingRow)) {//could maybe get rid of the is valid position check here

                if (this.boardState[columns[colIndex + updown_counter]][startingRow].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], startingRow]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex + updown_counter], startingRow]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/right side of the board
            while (colIndex + updown_counter > 5 && this.isValidPosition(columns[colIndex + updown_counter], new_starting_row - updown_counter)) {

                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row - updown_counter]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - updown_counter].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row - updown_counter]);
                    break;
                }
                updown_counter++;
            }

            //moving UP LEFT DIAGONAL ***
            updown_counter = 1;
                //on the right side of the board
            while (colIndex - updown_counter >= 5 && this.isValidPosition(columns[colIndex - updown_counter], startingRow + (updown_counter * 2))) {

                if (this.boardState[columns[colIndex - updown_counter]][startingRow + (updown_counter * 2)].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], startingRow + (updown_counter * 2)]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow + (updown_counter * 2)].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow + (updown_counter * 2)].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], startingRow + (updown_counter * 2)]);
                    break;
                }
                updown_counter++;
            }

            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/left side of the board
            while (colIndex - updown_counter < 5 && this.isValidPosition(columns[colIndex - updown_counter], new_starting_row + updown_counter)) {

                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row + updown_counter]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row + updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row + updown_counter].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row + updown_counter]);
                    break;
                }
                updown_counter++;
            }

        //moving UP RIGHT DIAGONAL ***
            updown_counter = 1;
                //on the left side of the board
            while (colIndex + updown_counter <= 5 && this.isValidPosition(columns[colIndex + updown_counter], startingRow + (updown_counter * 2))) {

                if (this.boardState[columns[colIndex + updown_counter]][startingRow + (updown_counter * 2)].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], startingRow + (updown_counter * 2)]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow + (updown_counter * 2)].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow + (updown_counter * 2)].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex + updown_counter], startingRow + (updown_counter * 2)]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/right side of the board
            while (colIndex + updown_counter > 5 && this.isValidPosition(columns[colIndex + updown_counter], new_starting_row + updown_counter)) {

                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row + updown_counter]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row + updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row + updown_counter].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row + updown_counter]);
                    break;
                }
                updown_counter++;
            }

        //moving DOWN LEFT DIAGONAL ***
            updown_counter = 1;
                //on the right side of the board
            while (colIndex - updown_counter >= 5 && this.isValidPosition(columns[colIndex - updown_counter], startingRow  - updown_counter)) {

                if (this.boardState[columns[colIndex - updown_counter]][startingRow  - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], startingRow  - updown_counter]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow  - updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow  - updown_counter].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], startingRow  - updown_counter]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/left side of the board
            while (colIndex - updown_counter < 5 && this.isValidPosition(columns[colIndex - updown_counter], new_starting_row - (updown_counter * 2))) {

                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - (updown_counter * 2)].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row - (updown_counter * 2)]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - (updown_counter * 2)].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - (updown_counter * 2)].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row - (updown_counter * 2)]);
                    break;
                }
                updown_counter++;
            }

        //moving DOWN RIGHT DIAGONAL ***
            updown_counter = 1;
                //on the left side of the board
            while (colIndex + updown_counter <= 5 && this.isValidPosition(columns[colIndex + updown_counter], startingRow - updown_counter)) {

                if (this.boardState[columns[colIndex + updown_counter]][startingRow - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], startingRow - updown_counter]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow - updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow - updown_counter].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex + updown_counter], startingRow - updown_counter]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/right side of the board
            while (colIndex + updown_counter > 5 && this.isValidPosition(columns[colIndex + updown_counter], new_starting_row - (updown_counter * 2))) {

                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - (updown_counter * 2)].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row - (updown_counter * 2)]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - (updown_counter * 2)].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - (updown_counter * 2)].color === "black") { //capturing a black piece
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row - (updown_counter * 2)]);
                    break;
                }
                updown_counter++;
            }

        //moving PERFECT LEFT ***
            updown_counter = 1;
                //on the right side of the board
            while (colIndex - (updown_counter * 2) > 4 && this.isValidPosition(columns[colIndex - (updown_counter * 2)], startingRow + updown_counter)) {

                if (this.boardState[columns[colIndex - (updown_counter * 2)]][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], startingRow + updown_counter]);
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][startingRow + updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][startingRow + updown_counter].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //crossing the middle column
            while (colIndex - (updown_counter * 2) == 4 && this.isValidPosition(columns[colIndex - (updown_counter * 2)], new_starting_row)) {

                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row].color === null) { //moving up
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], new_starting_row]);
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], new_starting_row]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = new_starting_row + updown_counter - 1;
                //on the left side of the board
            while (colIndex - (updown_counter * 2) < 4 && this.isValidPosition(columns[colIndex - (updown_counter * 2)], new_starting_row - updown_counter)) {

                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], new_starting_row - updown_counter]);
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row - updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row - updown_counter].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], new_starting_row - updown_counter]);
                    break;
                }
                updown_counter++;
            }

        //moving PERFECT RIGHT ***
            updown_counter = 1;
                //on the left side of the board
            while (colIndex + (updown_counter * 2) < 6 && this.isValidPosition(columns[colIndex + (updown_counter * 2)], startingRow + updown_counter)) {

                if (this.boardState[columns[colIndex + (updown_counter * 2)]][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], startingRow + updown_counter]);
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][startingRow + updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][startingRow + updown_counter].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //crossing the middle column
            while (colIndex + (updown_counter * 2) == 6 && this.isValidPosition(columns[colIndex + (updown_counter * 2)], new_starting_row)) {

                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row].color === null) { //moving up
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], new_starting_row]);
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], new_starting_row]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = new_starting_row + updown_counter - 1;
                //on the right side of the board
            while (colIndex + (updown_counter * 2) > 6 && this.isValidPosition(columns[colIndex + (updown_counter * 2)], new_starting_row - updown_counter)) {

                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], new_starting_row - updown_counter]);
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row - updown_counter].color === "white") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row - updown_counter].color === "black") { //capturing a piece
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], new_starting_row - updown_counter]);
                    break;
                }
                updown_counter++;
            }


            return valid_moves;
        }

        if (piece.color === "black" && piece.type === "queen") {

            //moving UP ***
            let updown_counter = 1;
            while (this.isValidPosition(startingColumn, startingRow + updown_counter)) {

                if (this.boardState[startingColumn][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([startingColumn, startingRow + updown_counter]);
                }
                if (this.boardState[startingColumn][startingRow + updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[startingColumn][startingRow + updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([startingColumn, startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }

            //moving DOWN ***
            updown_counter = 1;
            while (this.isValidPosition(startingColumn, startingRow - updown_counter)) {

                if ((this.boardState[startingColumn][startingRow - updown_counter]).type === null) { //moving down
                    valid_moves.push([startingColumn, startingRow - updown_counter]);
                }
                if (this.boardState[startingColumn][startingRow - updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[startingColumn][startingRow - updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([startingColumn, startingRow - updown_counter]);
                    break;
                }
                updown_counter++;
            }

            //moving UP LEFT ***
            updown_counter = 1;
                //on the right side of the board
            while (colIndex - updown_counter >= 5 && this.isValidPosition(columns[colIndex - updown_counter], startingRow + updown_counter)) {//could maybe get rid of the is valid position check here

                if (this.boardState[columns[colIndex - updown_counter]][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], startingRow + updown_counter]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow + updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow + updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }
            let new_starting_row = startingRow + updown_counter - 1;
                //on the middle/left side of the board
            while (colIndex - updown_counter < 5 && this.isValidPosition(columns[colIndex - updown_counter], new_starting_row)) {

                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row]);
                    break;
                }
                updown_counter++;
            }

            //moving UP RIGHT ***
            updown_counter = 1;
                //on the left side of the board
            while (colIndex + updown_counter <= 5 && this.isValidPosition(columns[colIndex + updown_counter], startingRow + updown_counter)) {//could maybe get rid of the is valid position check here

                if (this.boardState[columns[colIndex + updown_counter]][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], startingRow + updown_counter]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow + updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow + updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex + updown_counter], startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/right side of the board
            while (colIndex + updown_counter > 5 && this.isValidPosition(columns[colIndex + updown_counter], new_starting_row)) {

                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row]);
                    break;
                }
                updown_counter++;
            }

            //moving DOWN LEFT ***
            updown_counter = 1;
                //on the right side of the board
            while (colIndex - updown_counter >= 5 && this.isValidPosition(columns[colIndex - updown_counter], startingRow)) {//could maybe get rid of the is valid position check here

                if (this.boardState[columns[colIndex - updown_counter]][startingRow].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], startingRow]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], startingRow]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/left side of the board
            while (colIndex - updown_counter < 5 && this.isValidPosition(columns[colIndex - updown_counter], new_starting_row - updown_counter)) {

                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row - updown_counter]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row - updown_counter]);
                    break;
                }
                updown_counter++;
            }

            //moving DOWN RIGHT ***
            updown_counter = 1;
                //on the left side of the board
            while (colIndex + updown_counter <= 5 && this.isValidPosition(columns[colIndex + updown_counter], startingRow)) {//could maybe get rid of the is valid position check here

                if (this.boardState[columns[colIndex + updown_counter]][startingRow].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], startingRow]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex + updown_counter], startingRow]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/right side of the board
            while (colIndex + updown_counter > 5 && this.isValidPosition(columns[colIndex + updown_counter], new_starting_row - updown_counter)) {

                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row - updown_counter]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row - updown_counter]);
                    break;
                }
                updown_counter++;
            }
            //moving UP LEFT DIAGONAL ***
            updown_counter = 1;
            //on the right side of the board
        while (colIndex - updown_counter >= 5 && this.isValidPosition(columns[colIndex - updown_counter], startingRow + (updown_counter * 2))) {

            if (this.boardState[columns[colIndex - updown_counter]][startingRow + (updown_counter * 2)].color === null) { //moving up
                valid_moves.push([columns[colIndex - updown_counter], startingRow + (updown_counter * 2)]);
            }
            if (this.boardState[columns[colIndex - updown_counter]][startingRow + (updown_counter * 2)].color === "black") { //hitting your own piece
                break;
            }
            if (this.boardState[columns[colIndex - updown_counter]][startingRow + (updown_counter * 2)].color === "white") { //capturing a piece
                valid_moves.push([columns[colIndex - updown_counter], startingRow + (updown_counter * 2)]);
                break;
            }
            updown_counter++;
        }
        new_starting_row = startingRow + updown_counter - 1;
            //on the middle/left side of the board
        while (colIndex - updown_counter < 5 && this.isValidPosition(columns[colIndex - updown_counter], new_starting_row + updown_counter)) {

            if (this.boardState[columns[colIndex - updown_counter]][new_starting_row + updown_counter].color === null) { //moving up
                valid_moves.push([columns[colIndex - updown_counter], new_starting_row + updown_counter]);
            }
            if (this.boardState[columns[colIndex - updown_counter]][new_starting_row + updown_counter].color === "black") { //hitting your own piece
                break;
            }
            if (this.boardState[columns[colIndex - updown_counter]][new_starting_row + updown_counter].color === "white") { //capturing a piece
                valid_moves.push([columns[colIndex - updown_counter], new_starting_row + updown_counter]);
                break;
            }
            updown_counter++;
        }

        //moving UP RIGHT DIAGONAL ***
            updown_counter = 1;
                //on the left side of the board
            while (colIndex + updown_counter <= 5 && this.isValidPosition(columns[colIndex + updown_counter], startingRow + (updown_counter * 2))) {

                if (this.boardState[columns[colIndex + updown_counter]][startingRow + (updown_counter * 2)].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], startingRow + (updown_counter * 2)]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow + (updown_counter * 2)].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow + (updown_counter * 2)].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex + updown_counter], startingRow + (updown_counter * 2)]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/right side of the board
            while (colIndex + updown_counter > 5 && this.isValidPosition(columns[colIndex + updown_counter], new_starting_row + updown_counter)) {

                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row + updown_counter]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row + updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row + updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row + updown_counter]);
                    break;
                }
                updown_counter++;
            }

        //moving DOWN LEFT DIAGONAL ***
            updown_counter = 1;
                //on the right side of the board
            while (colIndex - updown_counter >= 5 && this.isValidPosition(columns[colIndex - updown_counter], startingRow  - updown_counter)) {

                if (this.boardState[columns[colIndex - updown_counter]][startingRow  - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], startingRow  - updown_counter]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow  - updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][startingRow  - updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], startingRow  - updown_counter]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/left side of the board
            while (colIndex - updown_counter < 5 && this.isValidPosition(columns[colIndex - updown_counter], new_starting_row - (updown_counter * 2))) {

                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - (updown_counter * 2)].color === null) { //moving up
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row - (updown_counter * 2)]);
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - (updown_counter * 2)].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - updown_counter]][new_starting_row - (updown_counter * 2)].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex - updown_counter], new_starting_row - (updown_counter * 2)]);
                    break;
                }
                updown_counter++;
            }

        //moving DOWN RIGHT DIAGONAL ***
            updown_counter = 1;
                //on the left side of the board
            while (colIndex + updown_counter <= 5 && this.isValidPosition(columns[colIndex + updown_counter], startingRow - updown_counter)) {

                if (this.boardState[columns[colIndex + updown_counter]][startingRow - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], startingRow - updown_counter]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow - updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][startingRow - updown_counter].color === "white") { //capturing a black piece
                    valid_moves.push([columns[colIndex + updown_counter], startingRow - updown_counter]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //on the middle/right side of the board
            while (colIndex + updown_counter > 5 && this.isValidPosition(columns[colIndex + updown_counter], new_starting_row - (updown_counter * 2))) {

                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - (updown_counter * 2)].color === null) { //moving up
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row - (updown_counter * 2)]);
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - (updown_counter * 2)].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + updown_counter]][new_starting_row - (updown_counter * 2)].color === "white") { //capturing a black piece
                    valid_moves.push([columns[colIndex + updown_counter], new_starting_row - (updown_counter * 2)]);
                    break;
                }
                updown_counter++;
            }

        //moving PERFECT LEFT ***
            updown_counter = 1;
                //on the right side of the board
            while (colIndex - (updown_counter * 2) > 4 && this.isValidPosition(columns[colIndex - (updown_counter * 2)], startingRow + updown_counter)) {

                if (this.boardState[columns[colIndex - (updown_counter * 2)]][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], startingRow + updown_counter]);
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][startingRow + updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][startingRow + updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //crossing the middle column
            while (colIndex - (updown_counter * 2) == 4 && this.isValidPosition(columns[colIndex - (updown_counter * 2)], new_starting_row)) {

                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row].color === null) { //moving up
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], new_starting_row]);
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], new_starting_row]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = new_starting_row + updown_counter - 1;
                //on the left side of the board
            while (colIndex - (updown_counter * 2) < 4 && this.isValidPosition(columns[colIndex - (updown_counter * 2)], new_starting_row - updown_counter)) {

                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], new_starting_row - updown_counter]);
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row - updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex - (updown_counter * 2)]][new_starting_row - updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex - (updown_counter * 2)], new_starting_row - updown_counter]);
                    break;
                }
                updown_counter++;
            }

        //moving PERFECT RIGHT ***
            updown_counter = 1;
                //on the left side of the board
            while (colIndex + (updown_counter * 2) < 6 && this.isValidPosition(columns[colIndex + (updown_counter * 2)], startingRow + updown_counter)) {

                if (this.boardState[columns[colIndex + (updown_counter * 2)]][startingRow + updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], startingRow + updown_counter]);
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][startingRow + updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][startingRow + updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], startingRow + updown_counter]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = startingRow + updown_counter - 1;
                //crossing the middle column
            while (colIndex + (updown_counter * 2) == 6 && this.isValidPosition(columns[colIndex + (updown_counter * 2)], new_starting_row)) {

                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row].color === null) { //moving up
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], new_starting_row]);
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], new_starting_row]);
                    break;
                }
                updown_counter++;
            }
            new_starting_row = new_starting_row + updown_counter - 1;
                //on the right side of the board
            while (colIndex + (updown_counter * 2) > 6 && this.isValidPosition(columns[colIndex + (updown_counter * 2)], new_starting_row - updown_counter)) {

                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row - updown_counter].color === null) { //moving up
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], new_starting_row - updown_counter]);
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row - updown_counter].color === "black") { //hitting your own piece
                    break;
                }
                if (this.boardState[columns[colIndex + (updown_counter * 2)]][new_starting_row - updown_counter].color === "white") { //capturing a piece
                    valid_moves.push([columns[colIndex + (updown_counter * 2)], new_starting_row - updown_counter]);
                    break;
                }
                updown_counter++;
            }


            return valid_moves;
        }

        if (piece.color === "white" && piece.type === "knight") {
                                        //mainly if statements here not while
            // move UP 2, LEFT 1
                //on the right side of board
                if (colIndex > 5){
                    if (this.isValidPosition(columns[colIndex - 1], startingRow + 3)){
                        if (this.boardState[columns[colIndex - 1]][startingRow + 3].color !== "white"){
                            valid_moves.push([columns[colIndex - 1], startingRow + 3]);
                        }
                    }
                }
                //on the left side of board, and center
                if (colIndex <= 5){
                    if (this.isValidPosition(columns[colIndex - 1], startingRow + 2)){
                        if (this.boardState[columns[colIndex - 1]][startingRow + 2].color !== "white"){
                            valid_moves.push([columns[colIndex - 1], startingRow + 2]);
                        }
                    }
                }
            
            // move UP 2, RIGHT 1
                //on right side/center
                if (colIndex >= 5){
                    if (this.isValidPosition(columns[colIndex + 1], startingRow + 2)){
                        if (this.boardState[columns[colIndex + 1]][startingRow + 2].color !== "white"){
                            valid_moves.push([columns[colIndex + 1], startingRow + 2]);
                        }
                    }
                }
                //on left side
                if (colIndex < 5){
                    if (this.isValidPosition(columns[colIndex + 1], startingRow + 3)){
                        if (this.boardState[columns[colIndex + 1]][startingRow + 3].color !== "white"){
                            valid_moves.push([columns[colIndex + 1], startingRow + 3]);
                        }
                    }
                }
            
                //review center cases for all of these: ****************
            // move UPPER RIGHT 2, UP 1
                //on right side
                if (colIndex > 5){
                    if (this.isValidPosition(columns[colIndex + 2], startingRow + 1)){
                        if (this.boardState[columns[colIndex + 2]][startingRow + 1].color !== "white"){
                            valid_moves.push([columns[colIndex + 2], startingRow + 1]);
                        }
                    }
                }
                //on left side
                if (colIndex <= 5){
                    if (this.isValidPosition(columns[colIndex + 2], startingRow + 3)){
                        if (this.boardState[columns[colIndex + 2]][startingRow + 3].color !== "white"){
                            valid_moves.push([columns[colIndex + 2], startingRow + 3]);
                        }
                    }
                }

            // move UPPER RIGHT 2, DOWN 1
                //on right side
                if (colIndex > 5){
                    if (this.isValidPosition(columns[colIndex + 3], startingRow - 1)){
                        if (this.boardState[columns[colIndex + 3]][startingRow - 1].color !== "white"){
                            valid_moves.push([columns[colIndex + 3], startingRow - 1]);
                        }
                    }
                }
                //on left side
                if (colIndex <= 5){
                    if (this.isValidPosition(columns[colIndex + 3], startingRow + 2)){
                        if (this.boardState[columns[colIndex + 3]][startingRow + 2].color !== "white"){
                            valid_moves.push([columns[colIndex + 3], startingRow + 2]);
                        }
                    }
                }

            // move LOWER RIGHT 2, UP 1
                //on right side
                if (colIndex > 5){
                    if (this.isValidPosition(columns[colIndex + 3], startingRow - 2)){
                        if (this.boardState[columns[colIndex + 3]][startingRow - 2].color !== "white"){
                            valid_moves.push([columns[colIndex + 3], startingRow - 2]);
                        }
                    }
                }
                //on left side
                if (colIndex <= 5){
                    if (this.isValidPosition(columns[colIndex + 3], startingRow + 1)){
                        if (this.boardState[columns[colIndex + 3]][startingRow + 1].color !== "white"){
                            valid_moves.push([columns[colIndex + 3], startingRow + 1]);
                        }
                    }
                }

            // move LOWER RIGHT 2, DOWN 1
                //on right side
                if (colIndex > 5){
                    if (this.isValidPosition(columns[colIndex + 3], startingRow - 2)){
                        if (this.boardState[columns[colIndex + 3]][startingRow - 2].color !== "white"){
                            valid_moves.push([columns[colIndex + 3], startingRow - 2]);
                        }
                    }
                }
                //on left side
                if (colIndex <= 5){
                    if (this.isValidPosition(columns[colIndex + 3], startingRow + 1)){
                        if (this.boardState[columns[colIndex + 3]][startingRow + 1].color !== "white"){
                            valid_moves.push([columns[colIndex + 3], startingRow + 1]);
                        }
                    }
                }

            // move DOWN 2, LEFT 1
                //on right side
                //on left side
            
            // move DOWN 2, RIGHT 1
                //on right side
                //on left side

            // move LOWER LEFT 2, DOWN 1
                //on right side
                //on left side

            // move LOWER LEFT 2, UP 1
                //on right side
                //on left side

            // move UPPER LEFT 2, DOWN 1
                //on right side
                //on left side

            // move UPPER LEFT 2, UP 1
                //on right side
                //on left side
            
            return valid_moves;
        }

        return [];
    }
  
    movePieceOnBoard(piece, fromColumn, fromRow, toColumn, toRow ) {
        this.boardState[toColumn][toRow] = piece;//put it in the desination tile
        this.boardState[fromColumn][fromRow] = {color: null, type: null};
        if (piece.hasMoved === false){
            piece.hasMoved = true;
        }
    }

    getPosition(column, row){
        return this.boardState[column][row].color, this.boardState[column][row].type;
    }
  
    getGameStatus() {
      // Check and return the current status of the game
      return this.gameStatus;
    }
  
    // ... other game-related methods
  }

export default HexChessGame;