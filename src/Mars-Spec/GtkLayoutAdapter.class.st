Class {
	#name : #GtkLayoutAdapter,
	#superclass : #GtkAdapter,
	#instVars : [
		'layout',
		'changeLayoutSubscription'
	],
	#category : #'Mars-Spec-Layout-Base'
}

{ #category : #testing }
GtkLayoutAdapter class >> isAbstract [ 

	^ super isAbstract 
		or: [ self = GtkLayoutAdapter ]
]

{ #category : #accessing }
GtkLayoutAdapter >> add: aPresenter constraints: constraints [
 
	self widgetDo: [ :gtkWidget | | childWidget |
		childWidget := self 
			basicAdd: aPresenter 
			constraints: constraints 
			to: gtkWidget.
		self addWidgetAlignment: constraints to: childWidget.
		childWidget show.
		"I'm keeping a reference to aPresenter into the built widget because in some cases 
		 it can be GC (in case of the on-the-fly creation, for example). 
		 Now this can be a real bad idea :)"
		childWidget data: aPresenter  ]
]

{ #category : #accessing }
GtkLayoutAdapter >> addWidgetAlignment: constraints to: gtkWidget [

 	layout vAlign
		ifNotNil: [ :align | gtkWidget vAlign: align asGtkAlign ].
 	layout hAlign 
		ifNotNil: [ :align | gtkWidget hAlign: align asGtkAlign ]
]

{ #category : #private }
GtkLayoutAdapter >> applyLayout: aLayout [

	self subclassResponsibility
]

{ #category : #private }
GtkLayoutAdapter >> basicAdd: aPresenter constraints: constraints to: aPanel [ 

	self subclassResponsibility
]

{ #category : #building }
GtkLayoutAdapter >> buildWidget [
	"We defer this until layout: (because then I will know what I have to create)"
	
	^ nil
]

{ #category : #building }
GtkLayoutAdapter >> buildWithSpec [
	"This provides some polymorphism with regular presenters to allow composition of layouts."
	
	^ self widget
]

{ #category : #building }
GtkLayoutAdapter >> buildWithSpec: aSpec [
	"This provides some polymorphism with regular presenters to allow composition of layouts."
	
	^ self widget
]

{ #category : #private }
GtkLayoutAdapter >> connectToEvents: aLayout [

	self presenter whenVisibleChangedDo: [ 	
		self presenter isVisible 
			ifTrue: [ widget show ] 
			ifFalse: [ widget hide ] ].
		
	aLayout whenChildrenAddedDo: [ :ann |
		self 
			add: ann child
			constraints: (aLayout constraintsFor: ann child) ].	
			
	aLayout whenChildrenRemovedDo: [ :ann |
		self remove: ann child ]
]

{ #category : #private }
GtkLayoutAdapter >> deferredLayout: aLayout [

	layout := aLayout.
	self applyLayout: aLayout
]

{ #category : #private }
GtkLayoutAdapter >> ensureAllChildrenAreRetained [
	
	self widget children do: [ :each |
		self ensureRetained: each ]
]

{ #category : #private }
GtkLayoutAdapter >> ensureRetained: aWidget [
	"When removing a widget from a container, GTK3 will decrement the reference count, 
	 maybe causing a GC of the widget removed. Since we don't know what will happen with this 
	 widget after removal (maybe is kept for later), we increment the reference count and 
	 we mark the object for autoRelease (ensuring it *will* be collected when no references 
	 in the image remains)"

	aWidget markForAutoRelease
]

{ #category : #protocol }
GtkLayoutAdapter >> layout: aLayout [

	GtkRunLoop defer: [
		self deferredLayout: aLayout ]
]

{ #category : #private }
GtkLayoutAdapter >> rebuild [ 
	| oldChildren |

	oldChildren := widget children.
	"keep old"
	oldChildren do: [ :each | each objectRef ].
	"hide"
	widget hide.
	"remove all"
	widget removeAll.
	"re-add all"
	layout children do: [ :each |
		self add: each constraints: (layout constraintsFor: each) ].
	"show"
	widget show.
	"now dispose"
	oldChildren do: [ :each | each objectUnref ].
]

{ #category : #removing }
GtkLayoutAdapter >> remove: aPresenter [
	| widgetToRemove |
	
	widgetToRemove := aPresenter adapter widget.
	self ensureRetained: widgetToRemove.
	^ self widgetDo: [ :w | 
		w remove: widgetToRemove ]
]

{ #category : #'accessing - children' }
GtkLayoutAdapter >> removeAll [

	self ensureAllChildrenAreRetained.
	self widgetDo: [ :w | w removeAll ]
]

{ #category : #protocol }
GtkLayoutAdapter >> removeSubWidgets [

	self widgetDo: [ :w |
		w removeAll ]
]

{ #category : #accessing }
GtkLayoutAdapter >> replaceLayoutWith: aLayout [
	
	self model adapter: (aLayout
		buildAdapterFor: self model
		bindings: self model application adapterBindings).
		
	self model owner adapter rebuild
]

{ #category : #protocol }
GtkLayoutAdapter >> takeKeyboardFocus [
	| presenters |

	presenters := self presenter presentersInFocusOrder.
	presenters ifNil: [ ^ self ]. 
		
	presenters 
		detect: [ :each | each canTakeKeyboardFocus ]
		ifFound: [ :aPresenter | aPresenter takeKeyboardFocus ]
]
