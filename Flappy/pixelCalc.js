
var pixelCalc = function(x, y, offset) {
	var y1 = y - (y%8);
	return 8*x + (80 * y1) + (y%8) + offset;
}

var calc = function(x, y) {
	return pixelCalc(x, y, 0x3000).toString(16);
}

for (var i=0; i<256; i+=8) {
	console.log(calc(0,i));
}