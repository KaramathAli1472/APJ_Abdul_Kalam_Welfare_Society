<template>
  <div class="upload-container">
    <div class="header-section">
      <div class="title-with-icon">
        <div class="icon-wrapper">
          📚
        </div>
        <div>
          <h2 class="page-title">Upload Syllabus</h2>
          <p class="page-subtitle">Upload syllabus for different grades and courses</p>
        </div>
      </div>
    </div>

    <div class="card upload-card">
      <div class="card-header">
        <h3 class="card-title">Upload New Syllabus</h3>
        <div class="upload-steps">
          <span class="step active">1</span>
          <span class="step-line"></span>
          <span class="step">2</span>
          <span class="step-line"></span>
          <span class="step">3</span>
        </div>
      </div>

      <form @submit.prevent="upload" class="upload-form">
        <!-- Grade Selection -->
        <div class="form-group">
          <label for="grade" class="form-label">
            Grade
            <span class="required">*</span>
          </label>
          <select
            v-model="selectedGrade"
            id="grade"
            required
            class="form-input"
          >
            <option value="">Select Grade</option>
            <option v-for="gradeOption in gradeOptions" :key="gradeOption.value" :value="gradeOption.value">
              {{ gradeOption.label }}
            </option>
          </select>
          <div class="input-hint">Select the grade for this syllabus</div>
        </div>

        <!-- Course Name -->
        <div class="form-group">
          <label for="course" class="form-label">
            Course/Subject Name
            <span class="required">*</span>
          </label>
          <input
            type="text"
            v-model="course"
            id="course"
            placeholder="e.g., Mathematics, Science, English, Computer Science"
            required
            class="form-input"
          />
          <div class="input-hint">Enter the course or subject name</div>
        </div>

        <!-- Format Selection -->
        <div class="form-group">
          <label class="form-label">
            Select Format
            <span class="required">*</span>
          </label>
          <div class="format-options">
            <div
              v-for="format in formatOptions"
              :key="format.value"
              class="format-option"
              :class="{ 'selected': selectedFormat === format.value }"
              @click="selectFormat(format.value)"
            >
              <div class="format-icon">
                {{ format.icon }}
              </div>
              <div class="format-info">
                <div class="format-name">{{ format.name }}</div>
                <div class="format-ext">{{ format.extensions }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- File Upload -->
        <div class="form-group">
          <label class="form-label">
            Upload File
            <span class="required">*</span>
          </label>

          <div
            class="file-upload-area"
            :class="{
              'has-file': file,
              'is-dragover': dragover,
              'format-image': selectedFormat === 'image'
            }"
            @dragover.prevent="handleDragOver"
            @dragleave.prevent="dragover = false"
            @drop.prevent="handleDrop"
            @click="triggerFileInput"
          >
            <input
              type="file"
              ref="fileInput"
              @change="handleFile"
              :accept="getAcceptExtensions()"
              required
              class="file-input-hidden"
            />

            <div class="upload-icon">
              {{ getFormatIcon() }}
            </div>

            <div v-if="!file" class="upload-content">
              <p class="upload-title">{{ getUploadTitle() }}</p>
              <p class="upload-subtitle">{{ getUploadSubtitle() }}</p>
              <div class="format-badge" :class="`badge-${selectedFormat}`">
                {{ getFormatBadgeText() }}
              </div>
            </div>

            <div v-else class="file-preview">
              <div class="file-icon">
                {{ getFileIcon() }}
              </div>
              <div class="file-info">
                <div class="file-name">{{ file.name }}</div>
                <div class="file-meta">
                  <span class="file-size">{{ formatFileSize(file.size) }}</span>
                  <span class="file-format">{{ getFileExtension() }}</span>
                </div>
                <div class="file-status" :class="`status-${validateFile()}`">
                  {{ getValidationStatus() }}
                </div>
                <div v-if="uploadProgress > 0" class="upload-progress">
                  <div class="progress-bar">
                    <div
                      class="progress-fill"
                      :style="{ width: uploadProgress + '%' }"
                    ></div>
                  </div>
                  <span class="progress-text">{{ Math.round(uploadProgress) }}%</span>
                </div>
              </div>
              <button
                type="button"
                class="remove-file-btn"
                @click.stop="removeFile"
              >
                ✕
              </button>
            </div>
          </div>

          <div class="file-requirements">
            <div class="requirement">
              <span class="requirement-icon">✓</span>
              Maximum file size: 10MB
            </div>
            <div class="requirement">
              <span class="requirement-icon">✓</span>
              Supported formats: JPG, JPEG, PNG
            </div>
          </div>
        </div>

        <!-- Form Actions -->
        <div class="form-actions">
          <button
            type="button"
            class="btn btn-secondary"
            @click="resetForm"
            :disabled="!selectedGrade && !course && !file"
          >
            Clear All
          </button>
          <button
            type="submit"
            class="btn btn-primary"
            :disabled="!selectedGrade || !course || !file || !validateFile() || isUploading"
            :class="{ 'loading': isUploading }"
          >
            <span v-if="!isUploading" class="btn-content">
              <span class="btn-icon">⬆️</span>
              Upload Syllabus
            </span>
            <span v-else class="btn-content">
              <span class="spinner"></span>
              Uploading... ({{ Math.round(uploadProgress) }}%)
            </span>
          </button>
        </div>
      </form>

      <div class="upload-hint">
        <div class="hint-icon">💡</div>
        <p>
          <strong>Tip:</strong> Make sure to select the correct grade and course name for better organization.
          Use high-quality images for better readability.
        </p>
      </div>
    </div>

    <!-- Success Message after Upload -->
    <div v-if="uploadSuccess" class="success-message-card">
      <div class="success-icon">✅</div>
      <div class="success-content">
        <h3>Upload Successful!</h3>
        <p>Your syllabus image has been uploaded to Cloudinary and saved to Firebase.</p>
        <div class="success-details">
          <p><strong>Grade:</strong> {{ getGradeLabel(selectedGrade) }}</p>
          <p><strong>Course:</strong> {{ course }}</p>
          <p><strong>File:</strong> {{ uploadedFileName }}</p>
          <p><strong>Uploaded at:</strong> {{ new Date().toLocaleString() }}</p>

          <!-- Image Preview -->
          <div v-if="uploadedFileUrl" class="image-preview-container">
            <h4>Image Preview:</h4>
            <div class="image-preview">
              <img :src="uploadedFileUrl" :alt="uploadedFileName" class="preview-image" />
            </div>
            <div class="image-actions">
              <button @click="viewImage" class="btn btn-primary">
                👁️ View Full Image
              </button>
              <button @click="downloadImage" class="btn btn-secondary">
                ⬇️ Download Image
              </button>
            </div>
          </div>
        </div>
        <button @click="resetSuccess" class="btn btn-secondary">
          Upload Another Syllabus
        </button>
      </div>
    </div>

    <!-- Error Message -->
    <div v-if="errorMessage" class="error-message-card">
      <div class="error-icon">❌</div>
      <div class="error-content">
        <h3>Upload Failed</h3>
        <p>{{ errorMessage }}</p>
        <button @click="errorMessage = ''" class="btn btn-secondary">
          Try Again
        </button>
      </div>
    </div>

    <!-- Image View Modal -->
    <div v-if="showImageModal" class="image-modal" @click="closeImageModal">
      <div class="image-modal-content" @click.stop>
        <button @click="closeImageModal" class="close-modal-btn">✕</button>
        <img :src="uploadedFileUrl" :alt="uploadedFileName" class="modal-image" />
        <div class="image-info">
          <p><strong>{{ uploadedFileName }}</strong></p>
          <button @click="downloadImage" class="btn btn-primary">
            ⬇️ Download Image
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue';
import axios from 'axios';
import { db, auth } from '../../firebase/firebase';
import { collection, addDoc, serverTimestamp } from 'firebase/firestore';

// Cloudinary configuration
const CLOUDINARY_CLOUD_NAME = 'drxe5e2nk';
const CLOUDINARY_UPLOAD_PRESET = 'syllabus';

// Cloudinary upload function for images - FIXED
const uploadToCloudinary = async (file, onProgress = null) => {
  try {
    console.log('Starting Cloudinary upload for image:', file.name);

    if (!file) {
      throw new Error('No file selected');
    }

    // Check file size (10MB)
    const maxSize = 10 * 1024 * 1024;
    if (file.size > maxSize) {
      throw new Error('Image size must be less than 10MB');
    }

    // Check file type - only images
    const allowedExtensions = ['jpg', 'jpeg', 'png'];
    const fileExtension = file.name.split('.').pop().toLowerCase();

    if (!allowedExtensions.includes(fileExtension)) {
      throw new Error('Invalid file type. Please upload JPG, JPEG, or PNG images only.');
    }

    // Prepare form data for image upload
    const formData = new FormData();
    formData.append('file', file);
    formData.append('upload_preset', CLOUDINARY_UPLOAD_PRESET);

    // Add timestamp for unique filename
    const timestamp = Date.now();
    const fileNameWithoutExt = file.name.replace(/\.[^/.]+$/, "");
    const uniqueFileName = `syllabus_${fileNameWithoutExt}_${timestamp}`;
    formData.append('public_id', uniqueFileName);

    console.log('Uploading image to Cloudinary...');

    const response = await axios.post(
      `https://api.cloudinary.com/v1_1/${CLOUDINARY_CLOUD_NAME}/upload`,
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
        timeout: 30000,
        onUploadProgress: (progressEvent) => {
          if (onProgress && progressEvent.total) {
            const progress = Math.round((progressEvent.loaded * 100) / progressEvent.total);
            onProgress(progress);
          }
        },
      }
    );

    console.log('Cloudinary upload successful:', {
      url: response.data.secure_url,
      format: response.data.format,
      width: response.data.width,
      height: response.data.height
    });

    return response.data;

  } catch (error) {
    console.error('Cloudinary upload error:', error);

    if (error.response) {
      console.error('Cloudinary response error:', error.response.data);
      throw new Error(`Image upload failed: ${error.response.data.error?.message || 'Unknown error'}`);
    } else if (error.request) {
      throw new Error('Network error. Please check your internet connection.');
    } else {
      throw new Error(error.message || 'Failed to upload image');
    }
  }
};

export default {
  name: 'SyllabusUpload',

  setup() {
    // Form fields
    const selectedGrade = ref('');
    const course = ref('');
    const file = ref(null);
    const selectedFormat = ref('image');

    // UI states
    const dragover = ref(false);
    const isUploading = ref(false);
    const uploadProgress = ref(0);
    const uploadSuccess = ref(false);
    const errorMessage = ref('');
    const showImageModal = ref(false);

    // Upload results
    const uploadedFileName = ref('');
    const uploadedFileUrl = ref('');

    // Refs
    const fileInput = ref(null);

    // Grade options
    const gradeOptions = [
      { value: '1', label: 'Grade 1' },
      { value: '2', label: 'Grade 2' },
      { value: '3', label: 'Grade 3' },
      { value: '4', label: 'Grade 4' },
      { value: '5', label: 'Grade 5' },
      { value: '6', label: 'Grade 6' },
      { value: '7', label: 'Grade 7' },
      { value: '8', label: 'Grade 8' },
      { value: '9', label: 'Grade 9' },
      { value: '10', label: 'Grade 10' },
    ];

    // Format options - only image
    const formatOptions = [
      { value: 'image', name: 'Image File', icon: '🖼️', extensions: '.jpg, .jpeg, .png' }
    ];

    // Get grade label from value
    const getGradeLabel = (gradeValue) => {
      const gradeObj = gradeOptions.find(g => g.value === gradeValue);
      return gradeObj ? gradeObj.label : gradeValue;
    };

    // Format selection
    const selectFormat = (format) => {
      selectedFormat.value = format;
      if (file.value && !validateFile()) {
        removeFile();
        showToast(`Please select an image file`, 'info');
      }
    };

    // File handling functions
    const getAcceptExtensions = () => {
      return '.jpg,.jpeg,.png';
    };

    const getFormatIcon = () => {
      return '🖼️';
    };

    const getUploadTitle = () => {
      return file.value ? 'File Selected' : 'Drop image here or click to upload';
    };

    const getUploadSubtitle = () => {
      return 'Supports JPG, JPEG, PNG images';
    };

    const getFormatBadgeText = () => {
      return 'Image Format';
    };

    const getFileIcon = () => {
      if (!file.value) return '🖼️';
      const ext = getFileExtension().toLowerCase();
      if (ext === 'jpg' || ext === 'jpeg') return '📷';
      if (ext === 'png') return '🖼️';
      return '📁';
    };

    const getFileExtension = () => {
      if (!file.value) return '';
      const name = file.value.name;
      const lastDot = name.lastIndexOf('.');
      return lastDot !== -1 ? name.slice(lastDot + 1).toLowerCase() : '';
    };

    const validateFile = () => {
      if (!file.value) return false;
      const ext = getFileExtension();
      const allowedExtensions = ['jpg', 'jpeg', 'png'];
      return allowedExtensions.includes(ext.toLowerCase());
    };

    const getValidationStatus = () => {
      if (!file.value) return 'No file';
      if (validateFile()) return 'Valid image ✓';
      return 'Invalid format ✗';
    };

    const handleFile = (e) => {
      errorMessage.value = '';

      if (e.target.files.length > 0) {
        const selectedFile = e.target.files[0];

        if (selectedFile.size > 10 * 1024 * 1024) {
          showToast('Image size must be less than 10MB', 'error');
          e.target.value = '';
          return;
        }

        file.value = selectedFile;

        if (validateFile()) {
          showToast(`${selectedFile.name} selected successfully!`, 'success');
        } else {
          showToast(`Please select a valid image file (JPG, JPEG, PNG)`, 'error');
          e.target.value = '';
          file.value = null;
        }
      }
    };

    const triggerFileInput = () => {
      if (fileInput.value) {
        fileInput.value.click();
      }
    };

    const handleDragOver = (e) => {
      e.preventDefault();
      dragover.value = true;
    };

    const handleDrop = (e) => {
      e.preventDefault();
      dragover.value = false;
      const files = e.dataTransfer.files;

      if (files.length > 0) {
        const droppedFile = files[0];

        if (droppedFile.size > 10 * 1024 * 1024) {
          showToast('Image size must be less than 10MB', 'error');
          return;
        }

        file.value = droppedFile;

        if (validateFile()) {
          showToast(`${droppedFile.name} dropped successfully!`, 'success');
        } else {
          showToast(`Please drop a valid image file`, 'error');
          file.value = null;
        }
      }
    };

    const removeFile = () => {
      file.value = null;
      uploadProgress.value = 0;
      if (fileInput.value) {
        fileInput.value.value = '';
      }
    };

    const formatFileSize = (bytes) => {
      if (bytes === 0) return '0 Bytes';
      const k = 1024;
      const sizes = ['Bytes', 'KB', 'MB', 'GB'];
      const i = Math.floor(Math.log(bytes) / Math.log(k));
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    };

    // Form reset
    const resetForm = () => {
      selectedGrade.value = '';
      course.value = '';
      selectedFormat.value = 'image';
      removeFile();
      uploadSuccess.value = false;
      errorMessage.value = '';
      showImageModal.value = false;
      showToast('Form cleared', 'info');
    };

    const resetSuccess = () => {
      uploadSuccess.value = false;
      uploadedFileName.value = '';
      uploadedFileUrl.value = '';
      resetForm();
    };

    // Image handling functions
    const viewImage = () => {
      showImageModal.value = true;
    };

    const closeImageModal = () => {
      showImageModal.value = false;
    };

    const downloadImage = () => {
      if (uploadedFileUrl.value) {
        const link = document.createElement('a');
        link.href = uploadedFileUrl.value;
        link.download = uploadedFileName.value;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        showToast('Image download started!', 'success');
      }
    };

    // Save to Firebase
    const saveToFirebase = async (cloudinaryResponse) => {
      try {
        const user = auth.currentUser;

        const cleanGrade = selectedGrade.value.trim();

        const uploadData = {
          // Main filter field
          grade: cleanGrade,

          // Display information
          gradeLabel: getGradeLabel(cleanGrade),

          courseName: course.value.trim(),

          fileName: file.value.name,
          fileSize: file.value.size,
          fileType: 'image',
          fileExtension: getFileExtension(),

          cloudinaryUrl: cloudinaryResponse.secure_url,
          cloudinaryPublicId: cloudinaryResponse.public_id,

          format: cloudinaryResponse.format,
          bytes: cloudinaryResponse.bytes,
          width: cloudinaryResponse.width,
          height: cloudinaryResponse.height,
          resourceType: cloudinaryResponse.resource_type,

          status: 'completed',
          academicYear: new Date().getFullYear(),

          createdAt: serverTimestamp(),
          timestamp: new Date().toISOString(),

          uploadedBy: user ? user.uid : 'anonymous',
          uploadedByName: user
            ? (user.displayName || user.email)
            : 'Anonymous',
        };

        console.log('✅ Saving syllabus with grade:', uploadData);

        const docRef = await addDoc(
          collection(db, 'syllabusUploads'),
          uploadData
        );

        console.log('✅ Firestore document ID:', docRef.id);
        return docRef.id;

      } catch (error) {
        console.error('❌ Firebase save error:', error);
        throw error;
      }
    };

    // Upload function
    const upload = async () => {
      // Validation
      if (!selectedGrade.value) {
        showToast('Please select a grade!', 'error');
        return;
      }

      if (!course.value.trim()) {
        showToast('Please enter a course name!', 'error');
        return;
      }

      if (!file.value) {
        showToast('Please select an image!', 'error');
        return;
      }

      if (!validateFile()) {
        showToast('Please select a valid image file (JPG, JPEG, PNG)!', 'error');
        return;
      }

      // Start upload
      isUploading.value = true;
      uploadProgress.value = 0;
      errorMessage.value = '';

      try {
        showToast('Uploading image to Cloudinary...', 'info');

        // Upload to Cloudinary
        const cloudinaryResponse = await uploadToCloudinary(
          file.value,
          (progress) => {
            uploadProgress.value = progress;
          }
        );

        if (!cloudinaryResponse.secure_url) {
          throw new Error('Cloudinary did not return a valid URL');
        }

        // Save to Firebase
        showToast('Saving to database...', 'info');
        await saveToFirebase(cloudinaryResponse);

        // Update UI with results
        uploadedFileName.value = file.value.name;
        uploadedFileUrl.value = cloudinaryResponse.secure_url;

        showToast(`✅ Syllabus image uploaded successfully!`, 'success');

        uploadSuccess.value = true;

        // Reset form but keep grade and course for reference
        file.value = null;
        uploadProgress.value = 0;
        if (fileInput.value) {
          fileInput.value.value = '';
        }

      } catch (error) {
        console.error('Upload error:', error);
        errorMessage.value = error.message;
        showToast(`Upload failed: ${error.message}`, 'error');
        uploadProgress.value = 0;
      } finally {
        isUploading.value = false;
      }
    };

    // Toast notification
    const showToast = (message, type = 'info') => {
      // Remove existing toasts
      const existingToasts = document.querySelectorAll('.toast');
      existingToasts.forEach(toast => toast.remove());

      // Create new toast
      const toast = document.createElement('div');
      toast.className = `toast toast-${type}`;
      toast.textContent = message;
      document.body.appendChild(toast);

      // Trigger animation
      setTimeout(() => {
        toast.classList.add('show');
      }, 10);

      // Remove toast after 3 seconds
      setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => {
          if (toast.parentNode) {
            document.body.removeChild(toast);
          }
        }, 300);
      }, 3000);
    };

    return {
      // Form data
      selectedGrade,
      course,
      file,
      selectedFormat,

      // UI states
      dragover,
      isUploading,
      uploadProgress,
      uploadSuccess,
      errorMessage,
      showImageModal,

      // Upload results
      uploadedFileName,
      uploadedFileUrl,

      // Refs
      fileInput,

      // Options
      gradeOptions,
      formatOptions,

      // Functions
      getGradeLabel,
      selectFormat,
      getAcceptExtensions,
      getFormatIcon,
      getUploadTitle,
      getUploadSubtitle,
      getFormatBadgeText,
      getFileIcon,
      getFileExtension,
      validateFile,
      getValidationStatus,
      handleFile,
      triggerFileInput,
      handleDragOver,
      handleDrop,
      removeFile,
      formatFileSize,
      resetForm,
      resetSuccess,
      viewImage,
      closeImageModal,
      downloadImage,
      upload,
      showToast
    };
  }
};
</script>

<style scoped>
.upload-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 24px;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.header-section {
  margin-bottom: 32px;
}

.title-with-icon {
  display: flex;
  align-items: center;
  gap: 16px;
}

.icon-wrapper {
  font-size: 40px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  width: 64px;
  height: 64px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.page-title {
  font-size: 28px;
  color: #2d3748;
  margin: 0 0 4px 0;
  font-weight: 700;
}

.page-subtitle {
  color: #718096;
  font-size: 16px;
  margin: 0;
}

.card {
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  padding: 32px;
  margin-bottom: 32px;
  border: 1px solid #e2e8f0;
}

.upload-card {
  border-top: 4px solid #667eea;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
}

.card-title {
  font-size: 20px;
  color: #2d3748;
  margin: 0;
  font-weight: 600;
}

.upload-steps {
  display: flex;
  align-items: center;
  gap: 8px;
}

.step {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #e2e8f0;
  color: #718096;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
}

.step.active {
  background: #667eea;
  color: white;
}

.step-line {
  width: 40px;
  height: 2px;
  background: #e2e8f0;
}

.upload-form {
  margin-bottom: 24px;
}

.form-group {
  margin-bottom: 28px;
}

.form-label {
  display: block;
  margin-bottom: 10px;
  font-weight: 600;
  color: #4a5568;
  font-size: 15px;
}

.required {
  color: #f56565;
  margin-left: 2px;
}

.form-input {
  width: 100%;
  padding: 14px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  font-size: 16px;
  transition: all 0.3s;
  background: #f8fafc;
  appearance: none;
}

.form-input:focus {
  outline: none;
  border-color: #667eea;
  background: white;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-input[type="file"] {
  padding: 12px;
}

.input-hint {
  font-size: 13px;
  color: #718096;
  margin-top: 6px;
}

.format-options {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
  margin-top: 12px;
}

.format-option {
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  padding: 16px;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 12px;
  background: white;
}

.format-option:hover {
  border-color: #cbd5e0;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.format-option.selected {
  border-color: #667eea;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
}

.format-icon {
  font-size: 28px;
  width: 48px;
  height: 48px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f0f4ff;
  color: #667eea;
}

.format-option.selected .format-icon {
  background: #667eea;
  color: white;
}

.format-info {
  flex: 1;
}

.format-name {
  font-weight: 600;
  color: #2d3748;
  margin-bottom: 4px;
}

.format-ext {
  font-size: 13px;
  color: #718096;
}

.file-upload-area {
  border: 2px dashed #cbd5e0;
  border-radius: 12px;
  padding: 40px 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
  background: #f8fafc;
  position: relative;
  overflow: hidden;
}

.file-upload-area:hover {
  border-color: #667eea;
  background: #f0f4ff;
}

.file-upload-area.has-file {
  border-color: #48bb78;
  background: #f0fff4;
}

.file-upload-area.is-dragover {
  border-color: #667eea;
  background: #e6f0ff;
  transform: scale(1.01);
}

.file-upload-area.format-pdf {
  border-color: #f56565;
}

.file-upload-area.format-doc {
  border-color: #4299e1;
}

.file-upload-area.format-excel {
  border-color: #38a169;
}

.file-input-hidden {
  display: none;
}

.upload-icon {
  font-size: 48px;
  margin-bottom: 16px;
  color: #a0aec0;
}

.file-upload-area.has-file .upload-icon {
  color: #48bb78;
}

.upload-title {
  font-size: 18px;
  color: #2d3748;
  margin: 0 0 8px 0;
  font-weight: 600;
}

.upload-subtitle {
  font-size: 14px;
  color: #718096;
  margin: 0 0 12px 0;
}

.format-badge {
  display: inline-block;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 600;
  color: white;
}

.badge-pdf {
  background: #f56565;
}

.badge-doc {
  background: #4299e1;
}

.badge-excel {
  background: #38a169;
}

.file-preview {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  animation: slideIn 0.3s ease;
  max-width: 600px;
  margin: 0 auto;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.file-icon {
  font-size: 40px;
  flex-shrink: 0;
}

.file-info {
  flex: 1;
  text-align: left;
}

.file-name {
  font-weight: 600;
  color: #2d3748;
  margin-bottom: 6px;
  word-break: break-all;
}

.file-meta {
  display: flex;
  gap: 16px;
  margin-bottom: 8px;
}

.file-size, .file-format {
  font-size: 13px;
  color: #718096;
  padding: 2px 8px;
  background: #f0f4ff;
  border-radius: 4px;
}

.file-status {
  font-size: 13px;
  font-weight: 600;
  margin-bottom: 8px;
}

.status-true {
  color: #38a169;
}

.status-false {
  color: #e53e3e;
}

.upload-progress {
  margin-top: 10px;
}

.progress-bar {
  width: 100%;
  height: 6px;
  background: #e2e8f0;
  border-radius: 3px;
  overflow: hidden;
  margin-bottom: 5px;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 3px;
  transition: width 0.3s ease;
}

.progress-text {
  font-size: 12px;
  color: #667eea;
  font-weight: 600;
}

.remove-file-btn {
  background: #fed7d7;
  color: #c53030;
  border: none;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
  flex-shrink: 0;
}

.remove-file-btn:hover {
  background: #feb2b2;
}

.file-requirements {
  display: flex;
  gap: 20px;
  margin-top: 16px;
  flex-wrap: wrap;
}

.requirement {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  color: #718096;
}

.requirement-icon {
  color: #48bb78;
  font-weight: bold;
}

.form-actions {
  display: flex;
  gap: 16px;
  justify-content: flex-end;
  margin-top: 32px;
}

.btn {
  padding: 12px 20px;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 120px;
  text-decoration: none;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none !important;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  position: relative;
}

.btn-primary:not(:disabled):hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.btn-secondary {
  background: #e2e8f0;
  color: #4a5568;
}

.btn-secondary:not(:disabled):hover {
  background: #cbd5e0;
}

.btn-content {
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-icon {
  font-size: 16px;
}

.spinner {
  width: 18px;
  height: 18px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  border-top-color: white;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.upload-hint {
  background: #ebf8ff;
  border-radius: 10px;
  padding: 16px;
  display: flex;
  align-items: flex-start;
  gap: 12px;
  border-left: 4px solid #4299e1;
}

.hint-icon {
  font-size: 20px;
  flex-shrink: 0;
}

.upload-hint p {
  margin: 0;
  color: #2b6cb0;
  font-size: 14px;
  line-height: 1.5;
}

.success-message-card {
  background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
  border-radius: 16px;
  padding: 32px;
  margin-top: 24px;
  border: 2px solid #28a745;
  animation: fadeIn 0.5s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.success-icon {
  font-size: 48px;
  text-align: center;
  margin-bottom: 20px;
}

.success-content {
  text-align: center;
}

.success-content h3 {
  color: #155724;
  margin-bottom: 12px;
  font-size: 24px;
}

.success-content p {
  color: #0f5132;
  margin-bottom: 20px;
  font-size: 16px;
}

.success-details {
  background: white;
  border-radius: 10px;
  padding: 20px;
  margin: 20px 0;
  text-align: left;
}

.success-details p {
  margin: 8px 0;
  color: #333;
}

.success-details h4 {
  margin: 16px 0 8px 0;
  color: #2d3748;
  font-size: 16px;
}

.file-view-options {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #e2e8f0;
}

.view-section {
  margin-bottom: 16px;
}

.view-buttons {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  margin-top: 10px;
}

.view-buttons .btn {
  padding: 10px 16px;
  font-size: 13px;
  min-width: auto;
}

.view-instructions {
  background: #f0fff4;
  border-radius: 8px;
  padding: 16px;
  margin-top: 16px;
  border: 1px solid #c6f6d5;
}

.view-instructions ol {
  margin: 8px 0 0 20px;
  padding: 0;
}

.view-instructions li {
  margin-bottom: 4px;
  color: #2d3748;
}

/* URL Copy Modal */
.url-copy-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  animation: fadeIn 0.3s ease;
}

.url-copy-container {
  background: white;
  border-radius: 12px;
  width: 90%;
  max-width: 600px;
  padding: 24px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
}

.url-copy-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 1px solid #e2e8f0;
}

.url-copy-header h3 {
  margin: 0;
  color: #2d3748;
  font-size: 20px;
}

.close-btn {
  background: #e2e8f0;
  border: none;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.3s;
}

.close-btn:hover {
  background: #cbd5e0;
}

.url-copy-body {
  margin-bottom: 20px;
}

.url-copy-body p {
  margin: 0 0 12px 0;
  color: #4a5568;
}

.url-input-group {
  display: flex;
  gap: 10px;
  margin: 16px 0;
}

.url-input {
  flex: 1;
  padding: 12px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 14px;
  background: #f8fafc;
  overflow: hidden;
  text-overflow: ellipsis;
}

.url-input:focus {
  outline: none;
  border-color: #667eea;
}

.url-actions {
  display: flex;
  gap: 10px;
  margin-top: 20px;
}

.url-actions .btn {
  flex: 1;
}

/* Error Message Card */
.error-message-card {
  background: linear-gradient(135deg, #f8d7da 0%, #f5c6cb 100%);
  border-radius: 16px;
  padding: 24px;
  margin-top: 20px;
  border: 2px solid #dc3545;
  animation: fadeIn 0.5s ease;
}

.error-icon {
  font-size: 40px;
  text-align: center;
  margin-bottom: 16px;
  color: #dc3545;
}

.error-content {
  text-align: center;
}

.error-content h3 {
  color: #721c24;
  margin-bottom: 10px;
  font-size: 20px;
}

.error-content p {
  color: #721c24;
  margin-bottom: 16px;
  font-size: 15px;
}

.error-content .btn {
  margin: 0 auto;
}

.toast {
  position: fixed;
  bottom: 24px;
  right: 24px;
  padding: 16px 24px;
  border-radius: 10px;
  color: white;
  font-weight: 500;
  z-index: 1000;
  opacity: 0;
  transform: translateY(20px);
  transition: all 0.3s;
  max-width: 320px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.toast.show {
  opacity: 1;
  transform: translateY(0);
}

.toast-success {
  background: #38a169;
}

.toast-error {
  background: #e53e3e;
}

.toast-info {
  background: #3182ce;
}

@media (max-width: 768px) {
  .upload-container {
    padding: 16px;
  }

  .card {
    padding: 20px 16px;
  }

  .title-with-icon {
    flex-direction: column;
    text-align: center;
    gap: 12px;
  }

  .format-options {
    grid-template-columns: 1fr;
  }

  .form-actions {
    flex-direction: column;
  }

  .btn {
    width: 100%;
    margin-bottom: 8px;
  }

  .file-requirements {
    flex-direction: column;
    gap: 10px;
  }

  .file-preview {
    flex-direction: column;
    text-align: center;
    padding: 16px;
  }

  .success-message-card,
  .error-message-card {
    padding: 20px;
  }

  .view-buttons {
    flex-direction: column;
  }

  .view-buttons .btn {
    width: 100%;
  }

  .url-input-group {
    flex-direction: column;
  }

  .url-actions {
    flex-direction: column;
  }
}
</style>