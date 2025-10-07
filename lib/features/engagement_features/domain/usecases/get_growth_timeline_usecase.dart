import '../entities/growth_timeline_entity.dart';

/// Get growth timeline use case
/// Follows master plan clean architecture
class GetGrowthTimelineUsecase {
  /// Execute get growth timeline
  Future<List<GrowthTimelineEntity>> execute() async {
    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 800));

    // Return sample growth timeline data for demo
    return [
      GrowthTimelineEntity(
        id: '1',
        month: 1,
        title: 'Newborn Stage',
        description:
            'Your baby is adjusting to life outside the womb. This is a time of rapid growth and development.',
        milestones: [
          'Lifts head briefly when on tummy',
          'Follows objects with eyes',
          'Responds to sounds',
          'Sleeps 14-17 hours per day',
        ],
        tips: [
          'Establish a feeding routine',
          'Practice tummy time daily',
          'Talk and sing to your baby',
          'Create a calm sleep environment',
        ],
        imageUrl: 'assets/images/month1.jpg',
        createdAt: DateTime.now(),
      ),
      GrowthTimelineEntity(
        id: '2',
        month: 2,
        title: 'Social Smiles Begin',
        description:
            'Your baby starts to recognize faces and may give you their first real smile.',
        milestones: [
          'Smiles responsively',
          'Coos and makes vowel sounds',
          'Holds head up for short periods',
          'Follows moving objects',
        ],
        tips: [
          'Respond to your baby\'s coos',
          'Make eye contact during feeding',
          'Read books with simple pictures',
          'Play gentle music',
        ],
        imageUrl: 'assets/images/month2.jpg',
        createdAt: DateTime.now(),
      ),
      GrowthTimelineEntity(
        id: '3',
        month: 3,
        title: 'Increased Awareness',
        description:
            'Your baby becomes more aware of their surroundings and starts to interact more.',
        milestones: [
          'Holds head steady when upright',
          'Reaches for objects',
          'Laughs and squeals',
          'Recognizes familiar faces',
        ],
        tips: [
          'Provide colorful toys',
          'Encourage reaching and grasping',
          'Play peek-a-boo',
          'Establish bedtime routines',
        ],
        imageUrl: 'assets/images/month3.jpg',
        createdAt: DateTime.now(),
      ),
      GrowthTimelineEntity(
        id: '4',
        month: 4,
        title: 'Rolling Over',
        description:
            'Your baby may start rolling over and showing more physical strength.',
        milestones: [
          'Rolls from tummy to back',
          'Bears weight on legs when held',
          'Brings hands to mouth',
          'Shows interest in solid foods',
        ],
        tips: [
          'Supervise tummy time closely',
          'Introduce age-appropriate toys',
          'Start solid food preparation',
          'Encourage independent play',
        ],
        imageUrl: 'assets/images/month4.jpg',
        createdAt: DateTime.now(),
      ),
      GrowthTimelineEntity(
        id: '5',
        month: 5,
        title: 'Sitting Up',
        description:
            'Your baby is gaining strength and may start sitting with support.',
        milestones: [
          'Sits with support',
          'Transfers objects between hands',
          'Responds to their name',
          'Shows stranger awareness',
        ],
        tips: [
          'Use supportive seating',
          'Play with stacking toys',
          'Introduce simple games',
          'Encourage self-feeding',
        ],
        imageUrl: 'assets/images/month5.jpg',
        createdAt: DateTime.now(),
      ),
      GrowthTimelineEntity(
        id: '6',
        month: 6,
        title: 'First Foods',
        description:
            'Your baby is ready for solid foods and shows increased mobility.',
        milestones: [
          'Sits without support',
          'Eats solid foods',
          'Passes objects between hands',
          'Babbles with different sounds',
        ],
        tips: [
          'Introduce single-ingredient foods',
          'Watch for food allergies',
          'Encourage self-feeding',
          'Maintain milk/formula feeding',
        ],
        imageUrl: 'assets/images/month6.jpg',
        createdAt: DateTime.now(),
      ),
    ];
  }
}
