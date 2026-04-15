/**
 * MongoDB Model: Health Education Content
 * Stores articles and educational content for chronic diseases
 */

const mongoose = require('mongoose');

const educationContentSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  slug: {
    type: String,
    required: true,
    unique: true
  },
  content: {
    type: String,
    required: true
  },
  summary: {
    type: String,
    required: true
  },
  category: {
    type: String,
    enum: ['diabetes', 'heart_disease', 'hypertension', 'asthma', 'cancer', 'mental_health', 'nutrition', 'exercise', 'preventive_care', 'maternal_health', 'child_health', 'elderly_care', 'general'],
    required: true,
    index: true
  },
  tags: [{
    type: String
  }],
  author: {
    name: String,
    credentials: String,
    avatar: String
  },
  cover_image: {
    type: String,
    default: ''
  },
  reading_time_minutes: {
    type: Number,
    default: 5
  },
  difficulty_level: {
    type: String,
    enum: ['beginner', 'intermediate', 'advanced'],
    default: 'beginner'
  },
  sources: [{
    title: String,
    url: String
  }],
  views: {
    type: Number,
    default: 0
  },
  likes: {
    type: Number,
    default: 0
  },
  is_published: {
    type: Boolean,
    default: true
  },
  published_at: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true,
  collection: 'education_content'
});

educationContentSchema.index({ category: 1, is_published: 1 });
educationContentSchema.index({ tags: 1 });
educationContentSchema.index({ '$**': 'text' });

const EducationContent = mongoose.model('EducationContent', educationContentSchema);

module.exports = EducationContent;
