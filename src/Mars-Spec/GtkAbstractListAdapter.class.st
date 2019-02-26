Class {
	#name : #GtkAbstractListAdapter,
	#superclass : #GtkAdapter,
	#category : #'Mars-Spec-Adapter'
}

{ #category : #building }
GtkAbstractListAdapter >> newTreeStore [

	^ self subclassResponsibility 
]

{ #category : #'as yet unclassified' }
GtkAbstractListAdapter >> refreshWidgetSelection [
	| rowIndexes |
	
	rowIndexes := self presenter selection selectedIndexes.
	(self widget selection allSelected collect: #first) asArray = rowIndexes
		ifTrue: [ ^ self ].
		
	rowIndexes ifEmpty: [ ^ self widget selection unselectAll ].

	self widget 	selection selectPath: rowIndexes.

]

{ #category : #building }
GtkAbstractListAdapter >> takeKeyboardFocus [

	| needToCleanUP |
	
	needToCleanUP := self presenter selection isEmpty.

	super takeKeyboardFocus.

	self flag: #hack.
	"GTK has an issue when giving the focus to a List. When it gives the focus selects the first element"
	
	needToCleanUP ifTrue: [ self widget selection unselectAll ]

]

{ #category : #building }
GtkAbstractListAdapter >> widgetClass [
	
	^ GtkTreeView
]