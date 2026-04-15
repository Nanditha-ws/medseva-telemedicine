/// Medication Reminder Model

class MedicationReminderModel {
  final String id;
  final String medicationName;
  final String dosage;
  final String frequency;
  final List<String> times;
  final String startDate;
  final String? endDate;
  final String? instructions;
  final String? prescribedBy;
  final bool isActive;
  final Map<String, dynamic>? prescribedByDoctor;

  MedicationReminderModel({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.times,
    required this.startDate,
    this.endDate,
    this.instructions,
    this.prescribedBy,
    this.isActive = true,
    this.prescribedByDoctor,
  });

  String get frequencyDisplay {
    switch (frequency) {
      case 'once_daily': return 'Once Daily';
      case 'twice_daily': return 'Twice Daily';
      case 'thrice_daily': return 'Thrice Daily';
      case 'four_times_daily': return '4 Times Daily';
      case 'weekly': return 'Weekly';
      case 'as_needed': return 'As Needed';
      default: return frequency;
    }
  }

  factory MedicationReminderModel.fromJson(Map<String, dynamic> json) {
    return MedicationReminderModel(
      id: json['id'] ?? '',
      medicationName: json['medication_name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      times: json['times'] != null ? List<String>.from(json['times']) : [],
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      instructions: json['instructions'],
      prescribedBy: json['prescribed_by'],
      isActive: json['is_active'] ?? true,
      prescribedByDoctor: json['prescribedByDoctor'],
    );
  }

  Map<String, dynamic> toJson() => {
    'medication_name': medicationName,
    'dosage': dosage,
    'frequency': frequency,
    'times': times,
    'start_date': startDate,
    'end_date': endDate,
    'instructions': instructions,
  };
}

/// Education Article Model
class EducationArticle {
  final String id;
  final String title;
  final String slug;
  final String? content;
  final String summary;
  final String category;
  final List<String> tags;
  final Map<String, dynamic>? author;
  final String? coverImage;
  final int readingTimeMinutes;
  final int views;
  final int likes;

  EducationArticle({
    required this.id,
    required this.title,
    required this.slug,
    this.content,
    required this.summary,
    required this.category,
    this.tags = const [],
    this.author,
    this.coverImage,
    this.readingTimeMinutes = 5,
    this.views = 0,
    this.likes = 0,
  });

  String get categoryDisplay {
    return category.replaceAll('_', ' ').split(' ').map((w) =>
      w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w
    ).join(' ');
  }

  String get authorName => author?['name'] ?? 'MedSeva Team';

  factory EducationArticle.fromJson(Map<String, dynamic> json) {
    return EducationArticle(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      content: json['content'],
      summary: json['summary'] ?? '',
      category: json['category'] ?? 'general',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      author: json['author'],
      coverImage: json['cover_image'],
      readingTimeMinutes: json['reading_time_minutes'] ?? 5,
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
    );
  }
}
