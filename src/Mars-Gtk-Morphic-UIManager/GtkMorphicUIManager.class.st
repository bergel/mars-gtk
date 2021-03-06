Class {
	#name : #GtkMorphicUIManager,
	#superclass : #MorphicUIManager,
	#category : #'Mars-Gtk-Morphic-UIManager'
}

{ #category : #activation }
GtkMorphicUIManager class >> activate [

	self default: self new
]

{ #category : #accessing }
GtkMorphicUIManager class >> isActiveManager [

	^ false
]

{ #category : #testing }
GtkMorphicUIManager class >> isValidForCurrentSystemConfiguration [

	^ false
]

{ #category : #debug }
GtkMorphicUIManager >> debugProcess: process context: context label: title fullView: bool notification: notificationString [
	"Open a notifier in response to an error, halt, or notify. A notifier view
	just shows a short view of the sender stack and provides a menu that
	lets the user open a full debugger."
	| debugSession inCallback |

	inCallback := GtkRunLoop current isInCallback.
	
	debugSession := process newDebugSessionNamed: title startedAt: context.
		 
	inCallback ifTrue: [ 
		debugSession spawnNewRunLoop.
		GtkRunLoop current callerProcess ifNotNil: [ :callerProcess |
			"force UI process if caller was correct"
			callerProcess = self uiProcess ifTrue: [
				debugSession oldUIProcess: callerProcess.  
				debugSession errorWasInUIProcess: true ] ] ].
	
	debugSession logStackToFileIfNeeded.
	debugSession isAboutUIProcess ifTrue: [ 
		DefaultExecutionEnvironment beActiveDuring: [ self spawnNewProcess ].
		debugSession newUIProcess: self uiProcess ].
		
	self defer:	[ 
			"schedule debugger in deferred UI message to address
			redraw problems after opening a debugger e.g. from
			the testrunner."
		[ 
			Smalltalk tools debugger 
				openOn: debugSession 
				withFullView: bool 
				andNotification: notificationString ] 
		on: Error 
		do: [ :ex | debugSession signalDebuggerError: ex ] 
	].

	process suspend.
	debugSession stopRunLoop
]

{ #category : #accessing }
GtkMorphicUIManager >> debugSessionClass [

	^ GtkDebugSession
]
