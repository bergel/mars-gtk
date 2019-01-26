Class {
	#name : #GtkNotebookAdapter,
	#superclass : #GtkAdapter,
	#category : #'Mars-Spec-Adapter'
}

{ #category : #building }
GtkNotebookAdapter >> addContentPage: gtkPage [	
	| box |
	
	box := gtkPage content.
	box hasChildren ifTrue: [ ^ self ].
	
	box 
		packStart: (self buildPage: gtkPage data retrievePresenter);
		showAll
]

{ #category : #building }
GtkNotebookAdapter >> addModelTo: gtkWidget [

	self model pages ifEmpty: [ ^ self ].
	self model pages do: [ :each |
		| page |
		
		page := gtkWidget 
			newPageLabel: (self buildLabelForTab: each) 
			content: GtkBox newVertical.
		page data: each.
		gtkWidget append: page ].
	"I add contents to fist page because this will shown anyway (and like this I allow
	 the layout to act correctly)"
	self addContentPage: gtkWidget children first. 
	gtkWidget connectSwitchPage: [ :aPage | 
		self addContentPage: aPage ].
]

{ #category : #building }
GtkNotebookAdapter >> buildLabelForTab: aPage [
	| label |

	label := GtkLabel newLabel: aPage title asString.
	aPage icon ifNotNil: [ :icon |
		label := GtkBox newHorizontal
			packStart: (GtkImage newForm: icon)
				expand: false 
				fill: false 
				padding: 0;
			packStart: label;
			showAll ].

	^ label
]

{ #category : #building }
GtkNotebookAdapter >> buildPage: aPresenter [

	^ SpecBindings 
	 	value: GtkAdapterBindings 
		during: [ aPresenter buildWithSpec ]

]

{ #category : #updating }
GtkNotebookAdapter >> updatePage: aPage [

	self widgetDo: [ :w | | widgetPage  |
		widgetPage := w children detect: [ :each | each data = aPage ]. 
		widgetPage updateLabel: (self buildLabelForTab: aPage) ]
]

{ #category : #building }
GtkNotebookAdapter >> widgetClass [

	^ GtkNotebook
]