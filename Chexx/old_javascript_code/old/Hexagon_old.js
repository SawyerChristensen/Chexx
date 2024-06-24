const angle = 2 * Math.PI / 6;

function drawHexagon(x, y, color) {
  
  ctx.strokeStyle = color;
  ctx.fillStyle = color;
  ctx.beginPath();

  for (var i = 0; i < 6; i++) {
    ctx.lineTo(x + r * Math.cos(angle * i),
               y + r * Math.sin(angle * i));
  }

  ctx.closePath();
  ctx.stroke();
  ctx.fill();
}

function drawAboveOf(color){
  y -= r * Math.sin(angle);
  y -= r * Math.sin(angle);
  drawHexagon(x, y, colors[color])
}

function drawBelowOf(color){
  y += r * Math.sin(angle);
  y += r * Math.sin(angle);
  drawHexagon(x, y, colors[color])
}

function drawUpperLeftOf(color){
  x -= r * (1 + Math.cos(angle));
  y -= r * Math.sin(angle);
  drawHexagon(x, y, colors[color]);
}

function drawBottomLeftOf(color){
  x -= r * (1 + Math.cos(angle));
  y += r * Math.sin(angle);
  drawHexagon(x, y, colors[color]);
}

function drawBottomRightOf(color){
  x += r * (1 + Math.cos(angle));
  y += r * Math.sin(angle);
  drawHexagon(x, y, colors[color]);
}

function drawUpperRightOf(color){
  x += r * (1 + Math.cos(angle));
  y -= r * Math.sin(angle);
  drawHexagon(x, y, colors[color]);
}