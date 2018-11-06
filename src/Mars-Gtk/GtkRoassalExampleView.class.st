Class {
	#name : #GtkRoassalExampleView,
	#superclass : #GtkDrawingArea,
	#instVars : [
		'view'
	],
	#category : #'Mars-Gtk-Examples'
}

{ #category : #private }
GtkRoassalExampleView class >> drawingAreaNew [
	^ self ffiCall: #(GtkRoassalExampleView *gtk_drawing_area_new ())
]

{ #category : #drawing }
GtkRoassalExampleView >> drawEmptyOn: canvas [
	
	canvas surface directDrawDuring: [ :c |
		canvas
			setPaint: Color cyan;
			drawShape: self allocation ]
]

{ #category : #drawing }
GtkRoassalExampleView >> drawOnAthensCanvas: aCanvas [
	
	self view 
		ifNotNil: [ self drawViewOn: aCanvas ]
		ifNil: [ self drawEmptyOn: aCanvas ]
]

{ #category : #drawing }
GtkRoassalExampleView >> drawViewOn: aCanvas [
	
	[ | morph |
		morph := TRMorph new.
		morph canvas: self view canvas.
		morph extent: self allocation extent.
		aCanvas surface directDrawDuring: [ :canvas |
			morph imageForm asMorph drawOnAthensCanvas: canvas ] ]
	on: Error 
	fork: [ :e | e pass ]
]

{ #category : #accessing }
GtkRoassalExampleView >> view [
	^ view
]

{ #category : #accessing }
GtkRoassalExampleView >> view: aView [

	view := aView.
	self queueDraw
]