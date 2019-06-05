"
I'm used to convert Gtk events into Morphic events to be passed to GtkMorphView instances.
"
Class {
	#name : #GtkMorphicEventHandler,
	#superclass : #OSWindowMorphicEventHandler,
	#category : #'Mars-Gtk-Morphic'
}

{ #category : #converting }
GtkMorphicEventHandler >> convertModifiers: anEvent [
	| modifiers |

	modifiers := 0.
	
	"Alt/Option key"
	anEvent hasAltModifier ifTrue: [
		"On windows and unix, treat alt key as command key"
		modifiers := Smalltalk os isWin32 | Smalltalk os isUnix
			ifTrue: [ modifiers | 2r01000000 ]
			ifFalse: [ modifiers | 2r00100000 ] ]. 
	
	anEvent hasControlModifier ifTrue: [ modifiers := modifiers | 2r00010000 ]. "Control key"
	anEvent hasShiftModifier ifTrue: [ modifiers := modifiers | 8 ]. "Shift key"
	anEvent hasMetaModifier ifTrue: [ modifiers := modifiers | 2r01000000 ]. "Cmd key"
	
	anEvent hasButton1Modifier ifTrue:  [ modifiers := modifiers | MouseButtonEvent redButton ].
	anEvent hasButton2Modifier ifTrue:  [ modifiers := modifiers | MouseButtonEvent blueButton ].
	anEvent hasButton3Modifier ifTrue:  [ modifiers := modifiers | MouseButtonEvent yellowButton ].
	
	^ modifiers
	
]

{ #category : #events }
GtkMorphicEventHandler >> dispatchMorphicEvent: anEvent [

	self activeHand handleEvent: anEvent
]

{ #category : #events }
GtkMorphicEventHandler >> handleEvent: anEvent [
	"convert the event to morphic one, and dispatch it whatever..."
	| morphicEvent |
	
	morphicEvent := anEvent accept: self.
	morphicEvent isMorphicEvent ifFalse: [ ^ false ].
	
	self dispatchMorphicEvent: morphicEvent.

	^ morphicEvent wasHandled
]

{ #category : #visiting }
GtkMorphicEventHandler >> visitUnknownEvent: anEvent [

	anEvent type crLog.
	^ nil
]