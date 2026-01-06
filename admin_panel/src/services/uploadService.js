import axios from 'axios';

// Cloudinary Configuration - Replace with your credentials
const CLOUDINARY_CLOUD_NAME = 'YOUR_CLOUDINARY_CLOUD_NAME';
const CLOUDINARY_UPLOAD_PRESET = 'YOUR_UPLOAD_PRESET';

// For testing, you can use these demo credentials (replace with yours)
// const CLOUDINARY_CLOUD_NAME = 'demo';
// const CLOUDINARY_UPLOAD_PRESET = 'docs_upload_example_us_preset';

/**
 * Upload file to Cloudinary
 * @param {File} file - The file to upload
 * @param {Function} onProgress - Progress callback
 * @returns {Promise} - Cloudinary response
 */
export const uploadToCloudinary = async (file, onProgress = null) => {
  try {
    // Validate file
    if (!file) {
      throw new Error('No file selected');
    }

    // Check file size (10MB limit)
    const maxSize = 10 * 1024 * 1024; // 10MB
    if (file.size > maxSize) {
      throw new Error('File size must be less than 10MB');
    }

    // Validate file type
    const allowedTypes = [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    ];

    if (!allowedTypes.includes(file.type)) {
      // Also check by extension for browser compatibility
      const ext = file.name.split('.').pop().toLowerCase();
      const allowedExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];
      if (!allowedExtensions.includes(ext)) {
        throw new Error('Invalid file type. Please upload PDF, Word, or Excel files only.');
      }
    }

    const formData = new FormData();
    formData.append('file', file);
    formData.append('upload_preset', CLOUDINARY_UPLOAD_PRESET);
    
    // Add folder based on file type
    const fileType = getFileType(file);
    formData.append('folder', `syllabus/${fileType}`);
    
    // Add timestamp for unique filename
    const timestamp = Date.now();
    formData.append('timestamp', timestamp);

    const response = await axios.post(
      `https://api.cloudinary.com/v1_1/${CLOUDINARY_CLOUD_NAME}/upload`,
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
        onUploadProgress: (progressEvent) => {
          if (onProgress && progressEvent.total) {
            const progress = progressEvent.loaded / progressEvent.total;
            onProgress(progress);
          }
        },
      }
    );

    console.log('Cloudinary upload successful:', response.data);
    return response.data;
  } catch (error) {
    console.error('Cloudinary upload error:', error);
    
    // More user-friendly error messages
    if (error.response) {
      // Cloudinary API error
      throw new Error(`Cloudinary upload failed: ${error.response.data.error.message || 'Unknown error'}`);
    } else if (error.request) {
      // Network error
      throw new Error('Network error. Please check your internet connection.');
    } else {
      // Other errors
      throw new Error(error.message || 'Failed to upload to Cloudinary');
    }
  }
};

/**
 * Get file type for Cloudinary folder
 */
const getFileType = (file) => {
  const ext = file.name.split('.').pop().toLowerCase();
  if (ext === 'pdf') return 'pdf';
  if (['doc', 'docx'].includes(ext)) return 'word';
  if (['xls', 'xlsx'].includes(ext)) return 'excel';
  return 'other';
};

/**
 * Get allowed file formats
 */
export const getAllowedFormats = () => {
  return {
    pdf: ['.pdf'],
    doc: ['.doc', '.docx'],
    excel: ['.xls', '.xlsx']
  };
};

/**
 * Get file extension
 */
export const getFileExtension = (fileName) => {
  return fileName.split('.').pop().toLowerCase();
};

/**
 * Validate file against selected format
 */
export const validateFileFormat = (file, selectedFormat) => {
  const ext = getFileExtension(file.name);
  const allowedFormats = getAllowedFormats();
  
  return allowedFormats[selectedFormat]?.includes(`.${ext}`) || false;
};

/**
 * Format file size
 */
export const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};