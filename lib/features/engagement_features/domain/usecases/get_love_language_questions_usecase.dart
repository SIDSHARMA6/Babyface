import '../entities/love_language_entity.dart';

/// Get love language questions use case
/// Follows master plan clean architecture
class GetLoveLanguageQuestionsUsecase {
  /// Execute get love language questions
  Future<List<LoveLanguageQuestionEntity>> execute() async {
    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 800));

    // Return sample love language questions for demo
    return [
      LoveLanguageQuestionEntity(
        id: '1',
        question: 'What makes you feel most loved by your partner?',
        category: LoveLanguageType.wordsOfAffirmation,
        order: 1,
        answers: [
          LoveLanguageAnswerEntity(
            id: '1a',
            text: 'When they tell me how much they love me',
            type: LoveLanguageType.wordsOfAffirmation,
            points: 3,
          ),
          LoveLanguageAnswerEntity(
            id: '1b',
            text: 'When they do things to help me',
            type: LoveLanguageType.actsOfService,
            points: 2,
          ),
          LoveLanguageAnswerEntity(
            id: '1c',
            text: 'When they give me thoughtful gifts',
            type: LoveLanguageType.receivingGifts,
            points: 1,
          ),
          LoveLanguageAnswerEntity(
            id: '1d',
            text: 'When we spend quality time together',
            type: LoveLanguageType.qualityTime,
            points: 2,
          ),
          LoveLanguageAnswerEntity(
            id: '1e',
            text: 'When they hold my hand or hug me',
            type: LoveLanguageType.physicalTouch,
            points: 1,
          ),
        ],
      ),
      LoveLanguageQuestionEntity(
        id: '2',
        question: 'How do you prefer to show love to your partner?',
        category: LoveLanguageType.actsOfService,
        order: 2,
        answers: [
          LoveLanguageAnswerEntity(
            id: '2a',
            text: 'By telling them how much they mean to me',
            type: LoveLanguageType.wordsOfAffirmation,
            points: 2,
          ),
          LoveLanguageAnswerEntity(
            id: '2b',
            text: 'By doing helpful things for them',
            type: LoveLanguageType.actsOfService,
            points: 3,
          ),
          LoveLanguageAnswerEntity(
            id: '2c',
            text: 'By buying them special gifts',
            type: LoveLanguageType.receivingGifts,
            points: 1,
          ),
          LoveLanguageAnswerEntity(
            id: '2d',
            text: 'By planning special dates together',
            type: LoveLanguageType.qualityTime,
            points: 2,
          ),
          LoveLanguageAnswerEntity(
            id: '2e',
            text: 'By being physically affectionate',
            type: LoveLanguageType.physicalTouch,
            points: 1,
          ),
        ],
      ),
      LoveLanguageQuestionEntity(
        id: '3',
        question: 'What would make you feel most appreciated?',
        category: LoveLanguageType.receivingGifts,
        order: 3,
        answers: [
          LoveLanguageAnswerEntity(
            id: '3a',
            text: 'A heartfelt compliment or praise',
            type: LoveLanguageType.wordsOfAffirmation,
            points: 2,
          ),
          LoveLanguageAnswerEntity(
            id: '3b',
            text: 'Help with household chores',
            type: LoveLanguageType.actsOfService,
            points: 1,
          ),
          LoveLanguageAnswerEntity(
            id: '3c',
            text: 'A thoughtful surprise gift',
            type: LoveLanguageType.receivingGifts,
            points: 3,
          ),
          LoveLanguageAnswerEntity(
            id: '3d',
            text: 'Undivided attention and conversation',
            type: LoveLanguageType.qualityTime,
            points: 2,
          ),
          LoveLanguageAnswerEntity(
            id: '3e',
            text: 'A warm hug or gentle touch',
            type: LoveLanguageType.physicalTouch,
            points: 1,
          ),
        ],
      ),
      LoveLanguageQuestionEntity(
        id: '4',
        question: 'When do you feel closest to your partner?',
        category: LoveLanguageType.qualityTime,
        order: 4,
        answers: [
          LoveLanguageAnswerEntity(
            id: '4a',
            text: 'When they express their feelings for me',
            type: LoveLanguageType.wordsOfAffirmation,
            points: 1,
          ),
          LoveLanguageAnswerEntity(
            id: '4b',
            text: 'When they help me with something important',
            type: LoveLanguageType.actsOfService,
            points: 1,
          ),
          LoveLanguageAnswerEntity(
            id: '4c',
            text: 'When they surprise me with something special',
            type: LoveLanguageType.receivingGifts,
            points: 1,
          ),
          LoveLanguageAnswerEntity(
            id: '4d',
            text: 'When we have deep conversations together',
            type: LoveLanguageType.qualityTime,
            points: 3,
          ),
          LoveLanguageAnswerEntity(
            id: '4e',
            text: 'When we cuddle or hold hands',
            type: LoveLanguageType.physicalTouch,
            points: 2,
          ),
        ],
      ),
      LoveLanguageQuestionEntity(
        id: '5',
        question: 'What makes you feel most secure in your relationship?',
        category: LoveLanguageType.physicalTouch,
        order: 5,
        answers: [
          LoveLanguageAnswerEntity(
            id: '5a',
            text: 'Hearing them say they love me',
            type: LoveLanguageType.wordsOfAffirmation,
            points: 2,
          ),
          LoveLanguageAnswerEntity(
            id: '5b',
            text: 'Knowing they\'ll be there to help me',
            type: LoveLanguageType.actsOfService,
            points: 1,
          ),
          LoveLanguageAnswerEntity(
            id: '5c',
            text: 'Receiving tokens of their affection',
            type: LoveLanguageType.receivingGifts,
            points: 1,
          ),
          LoveLanguageAnswerEntity(
            id: '5d',
            text: 'Spending uninterrupted time together',
            type: LoveLanguageType.qualityTime,
            points: 2,
          ),
          LoveLanguageAnswerEntity(
            id: '5e',
            text: 'Feeling their physical presence and touch',
            type: LoveLanguageType.physicalTouch,
            points: 3,
          ),
        ],
      ),
    ];
  }
}
