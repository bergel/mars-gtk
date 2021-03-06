Class {
	#name : #GtkOverlayAdapter,
	#superclass : #GtkLayoutAdapter,
	#category : #'Mars-Spec-Layout-Box'
}

{ #category : #private }
GtkOverlayAdapter >> applyLayout: aLayout [

	widget := GtkOverlay new.
	self connectToEvents: aLayout. 
	widget showAll.
]

{ #category : #private }
GtkOverlayAdapter >> basicAdd: aPresenter constraints: constraints to: aWidget [ 
	
	| childWidget |
	childWidget := aPresenter buildWithSpec: constraints spec.
	constraints isOverlay
		ifFalse: [
			aWidget add: childWidget ]
		ifTrue: [
			childWidget
				beHAlignCenter;
				beVAlignCenter.
			aWidget addOverlay: childWidget ].
	^ aWidget
]
