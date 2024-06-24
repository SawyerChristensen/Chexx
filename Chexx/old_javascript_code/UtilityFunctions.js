export function calculateHexagonPoints(centerX, centerY, radius) {//for hexagon.js
  const points = [];
  
  for (let i = 0; i < 6; i++) {
    const angle = (Math.PI / 3) * i;
    const x = centerX + radius * Math.cos(angle);
    const y = centerY + radius * Math.sin(angle);
    points.push(`${x},${y}`);
  }
  
  return points.join(' ');
};

export const calculateNewCenter = (x, y, radius, direction) => { //for board.js
  const angle = Math.PI / 3; // 60 degrees
  switch (direction) {
    case 'above':
      return { x, y: y - 2 * radius * Math.sin(angle) };
    case 'below':
      return { x, y: y + 2 * radius * Math.sin(angle) };
    case 'upperLeft':
      return { x: x - radius * (1 + Math.cos(angle)), y: y - radius * Math.sin(angle) };
    case 'bottomLeft':
      return { x: x - radius * (1 + Math.cos(angle)), y: y + radius * Math.sin(angle) };
    case 'upperRight':
      return { x: x + radius * (1 + Math.cos(angle)), y: y - radius * Math.sin(angle) };
    case 'bottomRight':
      return { x: x + radius * (1 + Math.cos(angle)), y: y + radius * Math.sin(angle) };
    default:
      return { x, y };
  }
};

export function splitKey(key) {
  'worklet';
  // Using regex to separate the letter and the number
  const match = key.match(/^([a-l])(\d+)$/);
  if (!match) {
      throw new Error("Invalid key format!");
  }
  const columnLetter = match[1];
  const rowIndex = parseInt(match[2] - 1); // maybe subtract 1 to use it as an array index?
  return { columnLetter, rowIndex };
}