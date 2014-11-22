//
//  Singleton.h
//  TweetQuiz
//
//  Created by Derek van Vliet on 09-12-15.
//  Copyright 2009 Get Set Games. All rights reserved.
//

//
// This macro implements the Cocoa singleton pattern.
// And is used by making the following call.
//       ClassName *cn = [ClassName sharedClassName];
//
// The macro is (with your class' name substituted for ClassName):
// CLASS_SINGLETON(ClassName)
// Creates the following class method:
//      + (ClassName *) sharedClassName;
// These NSObject methods are overridden:
//      + (void) initialize;
// When debugging, the below routines throw exceptions.
//      + (id)   allocWithZone: (NSZone *) zone;
//      - (id)   copyWithZone:  (NSZone *) zone;
//


#ifdef DEBUG
#define CLASS_SINGLETON(ClassName) \
\
static ClassName *shared##ClassName = nil; \
\
+ (ClassName *) sharedInstance { \
    return shared##ClassName; \
} \
\
+ (void) initialize { \
	if ( self == [ClassName class] ) { \
		if (!shared##ClassName) { \
			shared##ClassName = [ClassName new]; \
		} \
	} \
} \
\
+ (id) allocWithZone: (NSZone *) zone { \
	@synchronized(self) { \
		NSAssert(!shared##ClassName, @"There can be only one. No second calls to allocWithZone allowed."); \
		if (!shared##ClassName) { \
			shared##ClassName = [super allocWithZone:zone]; \
			return shared##ClassName; \
		} \
	} \
	return nil; \
} \
\
- (id) copyWithZone: (NSZone *) zone { \
	NSAssert(NO, @"Do not copy the singleton. There can be only one."); \
    return nil; \
}
#else
#define CLASS_SINGLETON(ClassName) \
\
static ClassName *shared##ClassName = nil; \
\
+ (ClassName *) sharedInstance { \
	return shared##ClassName; \
} \
\
+ (void) initialize { \
	if ( self == [ClassName class] ) { \
		if (!shared##ClassName) { \
			shared##ClassName = [ClassName new]; \
		} \
	} \
}
#endif


//
// Every static is a singleton and, if needed in a multithreaded class, 
// then it must be allocated in a thread safe fashion.
// The +initialize method needs three parameters:
//      ClassName:   This is used to make sure +initialize is called only once.
//      StaticClass: The class of the staic variable.
//      StaticName:  The name of the static variable.
//
#define STATIC_SINGLETON(ClassName, StaticClass, StaticName) \
\
static StaticClass *StaticName = nil; \
\
+ (void) initialize { \
	if ( self == [ClassName class] ) { \
		if (StaticName == nil) { \
			StaticName = [StaticClass new]; \
		} \
	} \
}
