/**
 * Document Controller
 * Handles document scanning, processing, and storage
 */

const ScannedDocument = require('../models/mongo/ScannedDocument');
const documentScanner = require('../services/opencv/documentScanner');

/**
 * Scan and process a document image
 * POST /api/documents/scan
 */
exports.scanDocument = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        status: 'error',
        message: 'Please upload an image to scan'
      });
    }

    const options = {
      applyThreshold: req.body.apply_threshold !== 'false',
      thresholdValue: parseInt(req.body.threshold_value) || 140,
      brightness: parseFloat(req.body.brightness) || 1.1,
      gamma: parseFloat(req.body.gamma) || 1.2
    };

    // Process the document
    const result = await documentScanner.processDocument(req.file.buffer, options);

    // Save to database
    const document = await ScannedDocument.create({
      user_id: req.user.id,
      title: req.body.title || `Scan_${new Date().toISOString().slice(0, 10)}`,
      document_type: req.body.document_type || 'other',
      original_image: result.original_image,
      processed_image: result.processed_image,
      processing_info: result.processing_info,
      tags: req.body.tags ? req.body.tags.split(',').map(t => t.trim()) : [],
      notes: req.body.notes || ''
    });

    res.status(201).json({
      status: 'success',
      message: 'Document scanned and processed successfully',
      data: {
        document,
        processing: result.processing_info
      }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Enhance an existing scanned document
 * POST /api/documents/:id/enhance
 */
exports.enhanceDocument = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        status: 'error',
        message: 'Please upload an image to enhance'
      });
    }

    const options = {
      grayscale: req.body.grayscale !== 'false',
      sharpen: req.body.sharpen !== 'false',
      contrast: req.body.contrast !== 'false',
      denoise: req.body.denoise !== 'false',
      rotate: parseInt(req.body.rotate) || 0
    };

    const result = await documentScanner.enhanceDocument(req.file.buffer, options);

    res.json({
      status: 'success',
      message: 'Document enhanced successfully',
      data: { enhanced_image: result }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Generate clean digital document
 * POST /api/documents/clean
 */
exports.generateCleanDocument = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        status: 'error',
        message: 'Please upload an image'
      });
    }

    const options = {
      format: req.body.format || 'jpeg',
      paperSize: req.body.paper_size || 'a4',
      dpi: parseInt(req.body.dpi) || 300
    };

    const result = await documentScanner.generateCleanDocument(req.file.buffer, options);

    res.json({
      status: 'success',
      message: 'Clean document generated',
      data: { clean_document: result }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Get all scanned documents
 * GET /api/documents
 */
exports.getDocuments = async (req, res, next) => {
  try {
    const { document_type, page = 1, limit = 20 } = req.query;
    const skip = (page - 1) * limit;

    let query = { user_id: req.user.id };
    if (document_type) query.document_type = document_type;

    const total = await ScannedDocument.countDocuments(query);
    const documents = await ScannedDocument.find(query)
      .sort({ createdAt: -1 })
      .skip(parseInt(skip))
      .limit(parseInt(limit));

    res.json({
      status: 'success',
      data: {
        documents,
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
 * Get scanned document by ID
 * GET /api/documents/:id
 */
exports.getDocumentById = async (req, res, next) => {
  try {
    const document = await ScannedDocument.findById(req.params.id);

    if (!document) {
      return res.status(404).json({
        status: 'error',
        message: 'Document not found'
      });
    }

    if (document.user_id !== req.user.id) {
      return res.status(403).json({ status: 'error', message: 'Access denied' });
    }

    res.json({
      status: 'success',
      data: { document }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Delete scanned document
 * DELETE /api/documents/:id
 */
exports.deleteDocument = async (req, res, next) => {
  try {
    const document = await ScannedDocument.findById(req.params.id);

    if (!document) {
      return res.status(404).json({
        status: 'error',
        message: 'Document not found'
      });
    }

    if (document.user_id !== req.user.id) {
      return res.status(403).json({ status: 'error', message: 'Access denied' });
    }

    await ScannedDocument.findByIdAndDelete(req.params.id);

    res.json({
      status: 'success',
      message: 'Document deleted successfully'
    });

  } catch (error) {
    next(error);
  }
};
