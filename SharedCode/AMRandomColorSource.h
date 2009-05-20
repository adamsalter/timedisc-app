//
//  AMRandomColorSource.h
//  TimeDisc
//
//  Created by Andreas on Wed Nov 13 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef struct _AMPoint3D {
    float x;
    float y;
	float z;
} AMPoint3D;

FOUNDATION_STATIC_INLINE float AMDistance3D(AMPoint3D point1, AMPoint3D point2)
{
	return sqrt(((point1.x-point2.x)*(point1.x-point2.x))+((point1.y-point2.y)*(point1.y-point2.y))+((point1.z-point2.z)*(point1.z-point2.z)));
}


@interface AMRandomColorSource : NSObject {
	NSImageView *_bitmapView;
	NSImage *_bitmapImage;
	NSBitmapImageRep *_bitmapRep;
	unsigned char *_bitmapPtr;
	float colorDeltaMax;
	float colorDeltaMin;
	float maxNeighbourDistance;
	NSPoint _lastPos;
}

- (id)init;

- (id)initWithColorMap;

- (id)initWithImage:(NSImage *)image;

- (id)initWithImageFromPath:(NSString *)imagePath;


- (NSImage *)image;
- (void)setImage:(NSImage *)newImage;

- (float)colorDeltaMax;
- (void)setColorDeltaMax:(float)newHueDeltaMax;

- (float)colorDeltaMin;
- (void)setColorDeltaMin:(float)newHueDeltaMin;

- (float)maxNeighbourDistance;
- (void)setMaxNeighbourDistance:(float)newMaxNeighbourDistance;


- (NSColor *)randomColor;

- (NSColor *)neighbourColor;

- (NSColor *)randomColorSimilarTo:(NSColor *)aColor;

- (NSColor *)randomColorDifferentFrom:(NSColor *)aColor;

- (BOOL)color:(NSColor *)firstColor isSimilarToColor:(NSColor *)secondColor;

- (BOOL)color:(NSColor *)firstColor isDifferentFromColor:(NSColor *)secondColor;


@end
