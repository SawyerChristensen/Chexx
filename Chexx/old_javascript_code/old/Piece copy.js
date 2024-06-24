import React from 'react';
import { Image as RNImage } from 'react-native';

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

const Piece = ({ x, y, radius, type, color }) => {
    const imageSource = pieceImages[`${color}_${type}`];

    return (
        <RNImage
          style={{
            position: 'absolute',
            left: x - radius * 0.75,
            top: y - radius * 0.8,
            width: radius * 1.5,
            height: radius * 1.5,
           }}
          source={imageSource}
        />
    );
};

export default Piece