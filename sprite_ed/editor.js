var w,h
var editorPixel=20
var previewPixel=2
var pixels
var currentColour

function getEditorCanvas() {
	return document.getElementById('editor')
}

function getEditorContext() {
	return getEditorCanvas().getContext('2d')
}

function getPreviewCanvas() {
	return document.getElementById('preview')
}

function getPreviewContext() {
	return getPreviewCanvas().getContext('2d')
}

function onload() {
	w=6
	h=4
	initCanvas(w, h)
}

function initCanvas(w, h) {
	var ed=getEditorCanvas()
	var pr=getPreviewCanvas()

	ed.width=w*editorPixel
	ed.height=h*editorPixel
	pr.width=w*previewPixel
	pr.height=h*previewPixel

	var edCont=getEditorContext()
	var prCont=getPreviewContext()

	edCont.fillStyle='black'
	edCont.fillRect(0, 0, ed.width, ed.height)


	prCont.fillStyle='black'
	prCont.fillRect(0, 0, pr.width, pr.height)

	edCont.strokeStyle='white'
	edCont.lineWidth=1

	var x=0,y=0
	for (var i=0;i<w-1;i++) {
		x += editorPixel
		edCont.moveTo((i+1) * editorPixel, 0)
		edCont.lineTo((i+1) * editorPixel, ed.height)
	}

	for (var j=0;j<h-1;j++) {
		y += editorPixel
		edCont.moveTo(0, (j+1) * editorPixel)
		edCont.lineTo(ed.width, (j+1) * editorPixel)
	}

	edCont.stroke()
	ed.addEventListener('mousedown', clickedPixel, false)

	var oldPixels
	if (pixels) {
		oldPixels = pixels
	}

	pixels = []
	pixels.length = w*h


}

function clickedPixel(e) {
	var x=e.offsetX
	var y=e.offsetY

	var pixelX = parseInt(x / editorPixel, 10)
	var pixelY = parseInt(y / editorPixel, 10)

	console.log('pixel: ' + pixelX + ', ' + pixelY)
}
