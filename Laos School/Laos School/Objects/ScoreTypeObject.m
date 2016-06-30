//
//  ScoreTypeObject.m
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScoreTypeObject.h"
#import "LocalizeHelper.h"

@implementation ScoreTypeObject

- (id)init {
    self = [super init];
    if (self) {
        self.scoreName = @"";
        self.scoreType = ScoreType_Normal;
        self.scoreKey = @"";
    }
    return self;
}


//- (void)encodeWithCoder:(NSCoder *)encoder {
//
//}
//
//- (id)initWithCoder:(NSCoder *)decoder {
//    if ((self = [super init])) // Superclass init
//    {
//
//    }
//    
//    return self;
//}

- (void)setScoreKey:(NSString *)scoreKey {
    _scoreKey = scoreKey;
    
    if ([_scoreKey isEqualToString:SCORE_KEY_SEP]) {
        _scoreName = LocalizedString(@"September score");
        _scoreShortName = LocalizedString(@"Sep");
        _scoreType = ScoreType_Normal;
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_OCT]) {
        _scoreName = LocalizedString(@"October score");
        _scoreShortName = LocalizedString(@"Oct");
        _scoreType = ScoreType_Normal;
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_NOV]) {
        _scoreName = LocalizedString(@"November score");
        _scoreShortName = LocalizedString(@"Nov");
        _scoreType = ScoreType_Normal;
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_DEC]) {
        _scoreName = LocalizedString(@"December score");
        _scoreShortName = LocalizedString(@"Dec");
        _scoreType = ScoreType_Normal;
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_AVE4M1]) {
        _scoreName = LocalizedString(@"Average 4 months");
        _scoreShortName = LocalizedString(@"Ave m1");
        _scoreType = ScoreType_Average;
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_TERM_EXAM1]) {
        _scoreName = LocalizedString(@"Term exam I");
        _scoreShortName = LocalizedString(@"Term exam I");
        _scoreType = ScoreType_Exam;
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_AVE_TERM1]) {
        _scoreName = LocalizedString(@"Average term 1");
        _scoreShortName = LocalizedString(@"Ave term I");
        _scoreType = ScoreType_TermFinal;
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_FEB]) {
        _scoreName = LocalizedString(@"February score");
        _scoreShortName = LocalizedString(@"Feb");
        _scoreType = ScoreType_Normal;
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_MAR]) {
        _scoreName = LocalizedString(@"March score");
        _scoreShortName = LocalizedString(@"Mar");
        _scoreType = ScoreType_Normal;
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_APR]) {
        _scoreName = LocalizedString(@"April score");
        _scoreShortName = LocalizedString(@"Apr");
        _scoreType = ScoreType_Normal;
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_MAY]) {
        _scoreName = LocalizedString(@"May score");
        _scoreShortName = LocalizedString(@"May");
        _scoreType = ScoreType_Normal;
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_AVE4M2]) {
        _scoreName = LocalizedString(@"Average 4 months");
        _scoreShortName = LocalizedString(@"Ave m2");
        _scoreType = ScoreType_Average;
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_TERM_EXAM2]) {
        _scoreName = LocalizedString(@"Term exam 2");
        _scoreShortName = LocalizedString(@"Test term II");
        _scoreType = ScoreType_Exam;
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_AVE_TERM2]) {
        _scoreName = LocalizedString(@"Average term 2");
        _scoreShortName = LocalizedString(@"Ave term II");
        _scoreType = ScoreType_TermFinal;
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_OVERALL]) {
        _scoreName = LocalizedString(@"Overall");
        _scoreShortName = LocalizedString(@"Ave year");
        _scoreType = ScoreType_YearFinal;
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_RETEST]) {
        _scoreName = LocalizedString(@"Retest");
        _scoreShortName = LocalizedString(@"Retest");
        _scoreType = ScoreType_ExamAgain;
        
    } else if ([_scoreKey isEqualToString:SCORE_KEY_GRADUATION]) {
        _scoreName = LocalizedString(@"Graduation");
        _scoreShortName = LocalizedString(@"Test grad");
        _scoreType = ScoreType_Graduate;
    }
}

@end