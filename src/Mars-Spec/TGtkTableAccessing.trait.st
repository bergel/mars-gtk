Trait {
	#name : #TGtkTableAccessing,
	#category : #'Mars-Spec'
}

{ #category : #building }
TGtkTableAccessing >> addColumn: aTableColumn to: aGtkTreeView [ 
	| addColumnVisitor |
	
	addColumnVisitor := GtkTableColumnBuilder new
		columns: self model columns;
		view: aGtkTreeView;
		yourself.
		
	aTableColumn acceptColumnVisitor: addColumnVisitor
]

{ #category : #building }
TGtkTableAccessing >> addColumnsTo: gtkWidget [

	self model columns do: [ :aColumn | 
		self addColumn: aColumn to: gtkWidget ].	
]

{ #category : #building }
TGtkTableAccessing >> addRows: aCollection to: store [

	aCollection withIndexDo: [ :anItem :index |
		self doAddRow: anItem index: index into: store ]
]

{ #category : #building }
TGtkTableAccessing >> addShownRowsTo: store [

	self 
		addRows: self model model shownItems
		to: store
]

{ #category : #building }
TGtkTableAccessing >> doAddRow: anObject index: rowIndex into: store [
	| row valueTransformer |

	row := store appendNew.
	valueTransformer := GtkTableRowFiller new
		columns: self model columns;
		gtkRow: row;
		row: anObject;
		rowIndex: rowIndex;
		yourself.

	self model columns do: [ :aColumn :columnIndex | 
		aColumn acceptColumnVisitor: valueTransformer ]
]

{ #category : #factory }
TGtkTableAccessing >> newTreeStore [
	| typeCollector store |
	
	typeCollector := GtkTableColumnTypeCollector new.
	self model columns do: [ :each | 
		typeCollector visit: each ].
	store := GtkTreeStore newColumnTypes: typeCollector types.
	self addShownRowsTo: store.

	^ store
]