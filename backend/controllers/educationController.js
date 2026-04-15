/**
 * Education Controller
 * Handles health education content for chronic diseases
 */

const EducationContent = require('../models/mongo/EducationContent');

/**
 * Get all education content
 * GET /api/education
 */
exports.getContent = async (req, res, next) => {
  try {
    const { category, search, page = 1, limit = 20 } = req.query;
    const skip = (page - 1) * limit;

    let query = { is_published: true };
    if (category) query.category = category;
    if (search) query.$text = { $search: search };

    const total = await EducationContent.countDocuments(query);
    const articles = await EducationContent.find(query)
      .sort({ published_at: -1 })
      .skip(parseInt(skip))
      .limit(parseInt(limit))
      .select('-content'); // Exclude full content in list view

    res.json({
      status: 'success',
      data: {
        articles,
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          total_pages: Math.ceil(total / limit)
        }
      }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Get article by slug
 * GET /api/education/:slug
 */
exports.getArticle = async (req, res, next) => {
  try {
    const article = await EducationContent.findOne({ 
      slug: req.params.slug,
      is_published: true 
    });

    if (!article) {
      return res.status(404).json({
        status: 'error',
        message: 'Article not found'
      });
    }

    // Increment view count
    await article.updateOne({ $inc: { views: 1 } });

    res.json({
      status: 'success',
      data: { article }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Get categories with article count
 * GET /api/education/categories
 */
exports.getCategories = async (req, res, next) => {
  try {
    const categories = await EducationContent.aggregate([
      { $match: { is_published: true } },
      { $group: { _id: '$category', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    res.json({
      status: 'success',
      data: { categories }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Create education content (admin/doctor only)
 * POST /api/education
 */
exports.createContent = async (req, res, next) => {
  try {
    // Generate slug from title
    const slug = req.body.title
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/(^-|-$)/g, '');

    const article = await EducationContent.create({
      ...req.body,
      slug,
      author: {
        name: `${req.user.first_name} ${req.user.last_name}`,
        credentials: req.body.author_credentials || '',
        avatar: req.user.profile_image || ''
      }
    });

    res.status(201).json({
      status: 'success',
      message: 'Article published successfully',
      data: { article }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Update education content
 * PUT /api/education/:id
 */
exports.updateContent = async (req, res, next) => {
  try {
    const article = await EducationContent.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true, runValidators: true }
    );

    if (!article) {
      return res.status(404).json({
        status: 'error',
        message: 'Article not found'
      });
    }

    res.json({
      status: 'success',
      message: 'Article updated',
      data: { article }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Like an article
 * POST /api/education/:id/like
 */
exports.likeArticle = async (req, res, next) => {
  try {
    const article = await EducationContent.findByIdAndUpdate(
      req.params.id,
      { $inc: { likes: 1 } },
      { new: true }
    );

    if (!article) {
      return res.status(404).json({
        status: 'error',
        message: 'Article not found'
      });
    }

    res.json({
      status: 'success',
      data: { likes: article.likes }
    });

  } catch (error) {
    next(error);
  }
};
