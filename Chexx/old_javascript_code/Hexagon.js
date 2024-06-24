import React from 'react';
import { Polygon } from 'react-native-svg';
import { calculateHexagonPoints } from './UtilityFunctions';

const Hexagon = ({ x, y, radius, color }) => {
  const points = calculateHexagonPoints(x, y, radius);

  return (
    <>
      <Polygon points={points} fill={color} />
    </>
  );
};

export default Hexagon;