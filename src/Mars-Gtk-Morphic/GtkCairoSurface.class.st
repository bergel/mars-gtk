"
I'm a cairo surface to be used on form rendering. 
It will create a cairo surface that does not needs to be mapped to RGBA (as my parent does).
"
Class {
	#name : #GtkCairoSurface,
	#superclass : #AthensCairoSurface,
	#pools : [
		'GtkTypes'
	],
	#category : #'Mars-Gtk-Morphic'
}

{ #category : #'instance creation' }
GtkCairoSurface class >> extent: anExtent [

	^ self platformClass
		extent: anExtent 
		format: CAIRO_FORMAT_RGB24
]

{ #category : #'instance creation' }
GtkCairoSurface class >> extent: anExtent format: aFormat [
	^ ( self primImage: aFormat width: anExtent x height: anExtent y) initialize

]

{ #category : #'instance creation' }
GtkCairoSurface class >> fromForm: aForm [
	| form surface |
	
	form := aForm unhibernate; asFormOfDepth: 32.
	surface := self extent: aForm extent.
	
	LibC 
		memCopy: form bits
		to: surface getDataPtr getHandle 
		size: (form width * form height * 4).
	
	surface markDirty.

	^ surface.

]

{ #category : #'instance creation' }
GtkCairoSurface class >> fromImageMorph: anImageMorph [
	| surface |

	surface := self extent: anImageMorph extent.
	surface drawDuring: [ :canvas |
		anImageMorph drawOnAthensCanvas: canvas ].
	
	^ surface
]

{ #category : #'instance creation' }
GtkCairoSurface class >> platformClass [
		
	OSPlatform current isMacOS ifTrue: [ ^ GtkQuartzCairoSurface ].
	^ self
]

{ #category : #private }
GtkCairoSurface class >> primImage: aFormat width: aWidth height: aHeight [

	^ self ffiCall: #(#GtkCairoSurface cairo_image_surface_create (
		int aFormat,
		int aWidth,
		int aHeight))

]

{ #category : #'private primitives' }
GtkCairoSurface >> cairoDestroy: cr [

	^ self 
		ffiCall: #(void cairo_destroy ("cairo_t *"void *cr))
		module: CairoLibrary
]

{ #category : #'private primitives' }
GtkCairoSurface >> cairoRectangle: aCr x: xValue y: yValue	width: aWidth height: aHeight [

	self 
		ffiCall: #(void cairo_rectangle (void *aCr,
                 double xValue,
                 double yValue,
                 double aWidth,
                 double aHeight))
		module: CairoLibrary
]

{ #category : #private }
GtkCairoSurface >> clipRectangleFrom: aCr [
	| rect |
	
	rect := GdkRectangle new.
	self getClipRectangle: rect from: aCr.
	^ rect asRectangle
]

{ #category : #'private primitives' }
GtkCairoSurface >> fill: cr [

	self 
		ffiCall: #(void cairo_fill (void *cr))
		module: CairoLibrary
]

{ #category : #'as yet unclassified' }
GtkCairoSurface >> fillInto: aCr [
	| rect |

	rect := self clipRectangleFrom: aCr.

"	cairo_set_source_surface (cr, src_surface, x_dest - x_src, y_dest - y_src);
	cairo_rectangle (cr, x_dest, y_dest, width, height);
	cairo_fill (cr);
"
	self 
		setSourceSurfaceTo: aCr
		surface: self getHandle
		x: 0.0 
		y: 0.0.

	self 
		cairoRectangle: aCr 
		x: rect origin x asFloat 
		y: rect origin y asFloat 
		width: rect width asFloat 
		height: rect height asFloat.

	self fill: aCr
]

{ #category : #'private primitives' }
GtkCairoSurface >> getClipRectangle: rect from: cr [
	
	^ self 
		ffiCall: #(gboolean gdk_cairo_get_clip_rectangle (
			"cairo_t *"void *cr,
  			GdkRectangle *rect))
		module: GLibLibrary
]

{ #category : #'private primitives' }
GtkCairoSurface >> paint: cr [

	self 
		ffiCall: #(void cairo_paint (void *cr))
		module: CairoLibrary
]

{ #category : #'as yet unclassified' }
GtkCairoSurface >> paintInto: cr at: origin [

	self 
		setSourceSurfaceTo: cr
		surface: self getHandle
		x: origin x asFloat
		y: origin y asFloat.
	self paint: cr.
	self cairoDestroy: cr
]

{ #category : #'private primitives' }
GtkCairoSurface >> setSourceSurfaceTo: cr surface: surface x: x y: y [

	self 
		ffiCall: #(void cairo_set_source_surface (void *cr, void *surface, double x, double y))
		module: CairoLibrary
]