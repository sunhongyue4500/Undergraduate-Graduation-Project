//
//  Shapefile.m
//  shpRead_ipad_02
//
//  Created by shy on 15/4/12.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import "Shapefile.h"
#import "ShapePolyline.h"
#import "ShapePoint.h"
#import "ShpHelper.h"

@implementation Shapefile


@synthesize shapefileType;
@synthesize	recordCount;
@synthesize fileLength;
@synthesize extendLeft;
@synthesize extendTop;
@synthesize extendRight;
@synthesize extendBottom;




int convertToLittleEndianInteger(void* pVal)
{
	
	int dwResult;
	
	memcpy((void*) ((unsigned long) &dwResult), (void*) ((unsigned long) pVal + 3), 1);
	memcpy((void*) ((unsigned long) &dwResult + 1), (void*) ((unsigned long) pVal + 2), 1);
	memcpy((void*) ((unsigned long) &dwResult + 2), (void*) ((unsigned long) pVal + 1), 1);
	memcpy((void*) ((unsigned long) &dwResult + 3), (void*) ((unsigned long) pVal), 1);
	
	return dwResult;
	
}


long convertToLittleEndianLong(long Val)
{
	
	long dwResult = Val;
	
	memcpy((void*) ((unsigned long) &dwResult), (void*) ((unsigned long) &Val + 3), 1);
	memcpy((void*) ((unsigned long) &dwResult + 1), (void*) ((unsigned long) &Val + 2), 1);
	memcpy((void*) ((unsigned long) &dwResult + 2), (void*) ((unsigned long) &Val + 1), 1);
	memcpy((void*) ((unsigned long) &dwResult + 3), (void*) ((unsigned long) &Val), 1);
	
	return dwResult;
	
}


-(BOOL)loadShapefile:(NSString *)strShapefile;
{

	m_objList = [[NSMutableArray alloc] init];
	char     *pBufferShapefile;
	void	 *pMain;
	int      nShapefileType;
	int      nRecord;
	long     nTotalContentLength = 100;
	long	 nContentLength = 0;
	
	
	m_strShapefile = strShapefile;
	m_data = [NSData dataWithContentsOfFile:m_strShapefile];
	
	pBufferShapefile = malloc([m_data length]);
    [m_data getBytes:pBufferShapefile length:[m_data length]];
	//[m_data getBytes:pBufferShapefile];
	
	pMain = &pBufferShapefile[0];
	
	// magic number of header block does not match (9994)
	if(convertToLittleEndianInteger(pMain) != 0x270a)
	{
		return NO;
	}
	
	//go to file length
	pMain = (void*) ((unsigned long) pMain + 24);	
	fileLength = 2 * convertToLittleEndianInteger(pMain);
	
	// go to version number
	pMain = (void*) ((unsigned long) pMain + 4);
	memcpy(&m_nVersion, pMain, 4);
	
	// version number should match (1000)
	if(m_nVersion != 0x03e8)
	{
		return NO;
	}
	
	// go to shape type
	pMain = (void*) ((unsigned long) pMain + 4);
	memcpy(&nShapefileType, pMain, 4);
	shapefileType = nShapefileType;
	
	if(nShapefileType != ShapefileTypePoint && nShapefileType != ShapefileTypePolyLine && nShapefileType != ShapefileTypePolygon)
	{
		return NO;
	}
	
	pMain = (void*) ((unsigned long) pMain + 4);
	
	double dExtendLeft, dExtendTop, dExtendRight, dExtendBottom;
	
	// get bounding box
	memcpy(&dExtendLeft, pMain, 8);
	extendLeft = (long)dExtendLeft;
	pMain = (void*) ((unsigned long) pMain + 8);
	memcpy(&dExtendBottom, pMain, 8);
	extendBottom = (long)dExtendBottom;
	pMain = (void*) ((unsigned long) pMain + 8);
	memcpy(&dExtendRight, pMain, 8);
	extendRight = (long)dExtendRight;
	pMain = (void*) ((unsigned long) pMain + 8);
	memcpy(&dExtendTop, pMain, 8);
	extendTop = (long)dExtendTop;
	pMain = (void*) ((unsigned long) pMain + 40);
	
	while(nTotalContentLength <= fileLength)
	{
		
		memcpy(&nRecord, pMain, 4);
        recordCount =  NSSwapBigIntToHost(nRecord);
		//recordCount = convertToLittleEndianLong(nRecord);
		pMain = (void*) ((unsigned long) pMain + 4);
		
		memcpy(&nContentLength, pMain, 4);
		nContentLength = convertToLittleEndianLong(nContentLength);
		
		nTotalContentLength = nTotalContentLength + (2 * nContentLength) + 8;
		
		pMain = (void*) ((unsigned long) pMain + 4);
		memcpy(&nShapefileType, pMain, 4);
		pMain = (void*) ((unsigned long) pMain + 4);
		
		if(nShapefileType == ShapefileTypePoint)
			pMain = [self parsePoint:pMain];
		
        //no problem before
		if((nShapefileType == ShapefileTypePolyLine) || (nShapefileType == ShapefileTypePolygon))
			pMain = [self parsePolyline:pMain];
		
		if(nTotalContentLength == fileLength)
		{
			
			return YES;
			
		}
		
	}

	return YES;
	
}


-(void *)parsePoint:(void *)pMain
{
	
	
	ShapePoint *shapePoint = [[ShapePoint alloc] init];
	
	memcpy(&shapePoint->m_nEast,  (void*) ((unsigned long) pMain), 8);
	memcpy(&shapePoint->m_nNorth, (void*) ((unsigned long) pMain + 8), 8);
	
	[m_objList addObject:shapePoint];
	
	pMain = (void*) ((unsigned long) pMain + 16);
	
	return pMain;
	
}


-(void *)parsePolyline:(void *)pMain
{
	
	long i;
	int nNumParts;
	int nNumPoints;
	int nPart;
	
	ShapePolyline *shapePolyline = [[ShapePolyline alloc] init];
	
	for(i = 0; i <= 3; i++)
	{
		memcpy(&(shapePolyline->m_nBoundingBox[i]), pMain, 8);
		pMain = (void*) ((unsigned long) pMain + 8);
	}
	

    
	memcpy(&nNumParts, pMain, 4);
    
    //此处容易出错
    //环的个数
	[shapePolyline setNumParts:nNumParts];
	
	pMain = (void*) ((unsigned long) pMain + 4);
	memcpy(&nNumPoints, pMain, 4);
    //构成所有环的点的数目
	[shapePolyline setNumPoints:nNumPoints];
	pMain = (void*) ((unsigned long) pMain + 4);
	
	for(i = 0; i < nNumParts; i++)
	{
		
		memcpy(&nPart, (void*) ((unsigned long) pMain + 4 * i), 4);
		NSNumber *part = [[NSNumber alloc] initWithInt:nPart];
		[shapePolyline->m_Parts addObject:part];
		
	}
	
	// read the elements (points)
	for(i = 0; i < nNumPoints; i++)
	{
		
		memcpy(&shapePolyline->m_nEast, (void*) ((unsigned long) pMain + 16 * i + (nNumParts * 4) ), 8);
		memcpy(&shapePolyline->m_nNorth, (void*) ((unsigned long) pMain + 16 * i + (nNumParts * 4) + 8), 8);
		ShapePoint* point = [[ShapePoint alloc] init];
		point->m_nEast = shapePolyline->m_nEast;
		point->m_nNorth = shapePolyline->m_nNorth;
		
		[shapePolyline->m_Points addObject:point];
		
	}
	
	[m_objList addObject:shapePolyline];
	
	pMain = (void*) ((unsigned long) pMain + (4 * nNumParts) + (16 * nNumPoints));
	
	return pMain;
	
}

@end