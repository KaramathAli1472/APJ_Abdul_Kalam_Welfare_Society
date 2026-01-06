<template>
  <div class="syllabus-list-container">
    <!-- Header Section -->
    <div class="header-section">
      <div class="title-group">
        <div class="icon-wrapper">
          <span class="icon">📚</span>
        </div>
        <div>
          <h1 class="page-title">Course Syllabus</h1>
          <p class="page-subtitle">Access and download all available course materials</p>
        </div>
      </div>
      <div class="header-actions">
        <div class="stats-card">
          <span class="stats-icon">📄</span>
          <div class="stats-content">
            <div class="stats-number">{{ syllabusList.length }}</div>
            <div class="stats-label">Total Syllabi</div>
          </div>
        </div>
        <button class="btn add-btn" @click="showAddModal">
          <span class="btn-icon">➕</span>
          Add Syllabus
        </button>
      </div>
    </div>

    <!-- Filters and Search -->
    <div class="controls-section">
      <div class="search-box">
        <span class="search-icon">🔍</span>
        <input 
          v-model="searchQuery" 
          type="text" 
          placeholder="Search courses, codes, or instructors..." 
          class="search-input"
          @input="handleSearch"
        />
        <button v-if="searchQuery" @click="clearSearch" class="clear-search-btn">
          ✕
        </button>
      </div>
      
      <div class="filter-group">
        <select v-model="selectedFormat" class="filter-select">
          <option value="all">All Formats</option>
          <option value="pdf">PDF Files</option>
          <option value="doc">Word Documents</option>
          <option value="excel">Excel Sheets</option>
          <option value="other">Other Formats</option>
        </select>
        
        <select v-model="sortBy" class="filter-select">
          <option value="course">Sort by Course</option>
          <option value="date">Sort by Date</option>
          <option value="size">Sort by Size</option>
          <option value="format">Sort by Format</option>
        </select>
        
        <button @click="toggleViewMode" class="view-toggle-btn">
          {{ viewMode === 'grid' ? '📋 List View' : '🔲 Grid View' }}
        </button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p class="loading-text">Loading course materials...</p>
      <p class="loading-subtext">Please wait while we fetch the syllabi</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="filteredSyllabi.length === 0" class="empty-state">
      <div class="empty-icon">
        <span>📭</span>
      </div>
      <h3 class="empty-title">No Syllabi Found</h3>
      <p class="empty-message" v-if="searchQuery">
        No courses found for "{{ searchQuery }}". Try a different search term.
      </p>
      <p class="empty-message" v-else>
        No syllabus materials are currently available. Check back later!
      </p>
      <button v-if="searchQuery" @click="clearSearch" class="btn btn-secondary">
        Clear Search
      </button>
      <button @click="showAddModal" class="btn add-btn">
        <span class="btn-icon">➕</span>
        Add First Syllabus
      </button>
    </div>

    <!-- Grid View -->
    <div v-else-if="viewMode === 'grid'" class="syllabus-grid">
      <div 
        v-for="item in filteredSyllabi" 
        :key="item.id" 
        class="syllabus-card"
        @mouseenter="hoveredCard = item.id"
        @mouseleave="hoveredCard = null"
      >
        <div class="card-header">
          <span class="format-badge" :class="getFormatClass(item.format || getFileFormat(item.fileURL))">
            {{ getFormatText(item.format || getFileFormat(item.fileURL)) }}
          </span>
          <div class="card-actions">
            <button 
              class="icon-btn edit-btn"
              @click.stop="editItem(item)"
              title="Edit"
            >
              ✏️
            </button>
            <button 
              class="icon-btn delete-btn"
              @click.stop="confirmDelete(item)"
              title="Delete"
            >
              🗑️
            </button>
            <button 
              class="icon-btn favorite-btn"
              :class="{ 'favorited': item.isFavorited }"
              @click.stop="toggleFavorite(item)"
              :title="item.isFavorited ? 'Remove from favorites' : 'Add to favorites'"
            >
              {{ item.isFavorited ? '⭐' : '☆' }}
            </button>
          </div>
        </div>
        
        <div class="card-body">
          <div class="course-info">
            <h3 class="course-title">{{ item.course || 'Unnamed Course' }}</h3>
            <p class="course-code" v-if="item.courseCode">
              {{ item.courseCode }}
            </p>
            <p class="instructor" v-if="item.instructor">
              <span class="instructor-icon">👨‍🏫</span> {{ item.instructor }}
            </p>
          </div>
          
          <div class="file-info">
            <div class="file-icon" :class="getFileIconClass(item.fileURL)">
              {{ getFileIcon(item.fileURL) }}
            </div>
            <div class="file-details">
              <p class="file-name" :title="getFileName(item.fileURL)">
                {{ truncateText(getFileName(item.fileURL), 25) }}
              </p>
              <div class="file-meta">
                <span class="file-size" v-if="item.fileSize">
                  {{ formatFileSize(item.fileSize) }}
                </span>
                <span class="file-date" v-if="item.uploadDate">
                  {{ formatDate(item.uploadDate) }}
                </span>
              </div>
            </div>
          </div>
          
          <div class="course-description" v-if="item.description">
            {{ truncateText(item.description, 100) }}
          </div>
        </div>
        
        <div class="card-footer">
          <button 
            class="btn preview-btn"
            @click="previewFile(item)"
            :disabled="!canPreview(item.fileURL)"
          >
            <span class="btn-icon">👁️</span>
            Preview
          </button>
          <button 
            class="btn download-btn"
            @click="downloadFile(item)"
          >
            <span class="btn-icon">⬇️</span>
            Download
          </button>
        </div>
        
        <div class="card-hover-overlay" v-if="hoveredCard === item.id">
          <div class="hover-actions">
            <button class="hover-action-btn" @click="shareFile(item)" title="Share">
              📤
            </button>
            <button class="hover-action-btn" @click="copyLink(item)" title="Copy Link">
              🔗
            </button>
            <button class="hover-action-btn" @click="showDetails(item)" title="Details">
              ℹ️
            </button>
            <button class="hover-action-btn" @click="editItem(item)" title="Edit">
              ✏️
            </button>
            <button class="hover-action-btn delete-hover-btn" @click="confirmDelete(item)" title="Delete">
              🗑️
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- List View -->
    <div v-else class="syllabus-table-container">
      <div class="table-wrapper">
        <table class="syllabus-table">
          <thead>
            <tr>
              <th @click="sortTable('course')" class="sortable-header">
                Course
                <span class="sort-icon" v-if="sortBy === 'course'">
                  {{ sortDirection === 'asc' ? '↑' : '↓' }}
                </span>
              </th>
              <th @click="sortTable('instructor')" class="sortable-header">
                Instructor
                <span class="sort-icon" v-if="sortBy === 'instructor'">
                  {{ sortDirection === 'asc' ? '↑' : '↓' }}
                </span>
              </th>
              <th>File</th>
              <th @click="sortTable('format')" class="sortable-header">
                Format
                <span class="sort-icon" v-if="sortBy === 'format'">
                  {{ sortDirection === 'asc' ? '↑' : '↓' }}
                </span>
              </th>
              <th @click="sortTable('date')" class="sortable-header">
                Upload Date
                <span class="sort-icon" v-if="sortBy === 'date'">
                  {{ sortDirection === 'asc' ? '↑' : '↓' }}
                </span>
              </th>
              <th @click="sortTable('size')" class="sortable-header">
                Size
                <span class="sort-icon" v-if="sortBy === 'size'">
                  {{ sortDirection === 'asc' ? '↑' : '↓' }}
                </span>
              </th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in filteredSyllabi" :key="item.id">
              <td class="course-cell">
                <div class="course-cell-content">
                  <span class="course-icon">📚</span>
                  <div>
                    <div class="course-name">{{ item.course }}</div>
                    <div class="course-code-small" v-if="item.courseCode">
                      {{ item.courseCode }}
                    </div>
                  </div>
                </div>
              </td>
              <td>
                <div class="instructor-cell">
                  <span class="instructor-icon-small">👨‍🏫</span>
                  {{ item.instructor || 'N/A' }}
                </div>
              </td>
              <td>
                <div class="file-cell">
                  <span class="file-icon-small" :class="getFileIconClass(item.fileURL)">
                    {{ getFileIcon(item.fileURL) }}
                  </span>
                  <div class="file-info-small">
                    <div class="file-name-small" :title="getFileName(item.fileURL)">
                      {{ truncateText(getFileName(item.fileURL), 20) }}
                    </div>
                  </div>
                </div>
              </td>
              <td>
                <span class="format-tag" :class="getFormatClass(item.format || getFileFormat(item.fileURL))">
                  {{ getFormatText(item.format || getFileFormat(item.fileURL)) }}
                </span>
              </td>
              <td>
                <div class="date-cell">
                  {{ formatDate(item.uploadDate) || 'N/A' }}
                </div>
              </td>
              <td>
                <span class="size-badge">
                  {{ item.fileSize ? formatFileSize(item.fileSize) : 'N/A' }}
                </span>
              </td>
              <td>
                <div class="action-buttons">
                  <button 
                    class="action-btn preview-btn"
                    @click="previewFile(item)"
                    :disabled="!canPreview(item.fileURL)"
                    title="Preview"
                  >
                    👁️
                  </button>
                  <button 
                    class="action-btn download-btn"
                    @click="downloadFile(item)"
                    title="Download"
                  >
                    ⬇️
                  </button>
                  <button 
                    class="action-btn edit-btn"
                    @click="editItem(item)"
                    title="Edit"
                  >
                    ✏️
                  </button>
                  <button 
                    class="action-btn delete-btn"
                    @click="confirmDelete(item)"
                    title="Delete"
                  >
                    🗑️
                  </button>
                  <button 
                    class="action-btn favorite-btn"
                    :class="{ 'favorited': item.isFavorited }"
                    @click="toggleFavorite(item)"
                    :title="item.isFavorited ? 'Remove favorite' : 'Add favorite'"
                  >
                    {{ item.isFavorited ? '⭐' : '☆' }}
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- File Preview Modal -->
    <div v-if="previewItem" class="modal-overlay" @click="closePreview">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <div class="modal-title-group">
            <h3>{{ previewItem.course }}</h3>
            <p class="modal-subtitle" v-if="previewItem.courseCode">
              {{ previewItem.courseCode }}
            </p>
          </div>
          <button class="close-btn" @click="closePreview">✕</button>
        </div>
        
        <div class="modal-body">
          <div v-if="isPdfFile(previewItem.fileURL)" class="pdf-preview">
            <iframe 
              :src="previewItem.fileURL" 
              class="pdf-frame"
              frameborder="0"
            ></iframe>
          </div>
          <div v-else class="other-preview">
            <div class="preview-placeholder">
              <div class="preview-icon">
                {{ getFileIcon(previewItem.fileURL) }}
              </div>
              <h4>File Preview Not Available</h4>
              <p>This file format cannot be previewed in the browser.</p>
              <button class="btn download-btn-large" @click="downloadFile(previewItem)">
                Download {{ getFormatText(getFileFormat(previewItem.fileURL)) }} File
              </button>
            </div>
          </div>
        </div>
        
        <div class="modal-footer">
          <div class="file-info-modal">
            <div class="info-item">
              <span class="info-label">File Name:</span>
              <span class="info-value">{{ getFileName(previewItem.fileURL) }}</span>
            </div>
            <div class="info-item" v-if="previewItem.fileSize">
              <span class="info-label">File Size:</span>
              <span class="info-value">{{ formatFileSize(previewItem.fileSize) }}</span>
            </div>
            <div class="info-item" v-if="previewItem.instructor">
              <span class="info-label">Instructor:</span>
              <span class="info-value">{{ previewItem.instructor }}</span>
            </div>
          </div>
          <div class="modal-actions">
            <button class="btn btn-secondary" @click="closePreview">
              Close
            </button>
            <button class="btn download-btn" @click="downloadFile(previewItem)">
              Download File
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Add/Edit Syllabus Modal -->
    <div v-if="showModal" class="modal-overlay" @click="closeModal">
      <div class="modal-content edit-modal" @click.stop>
        <div class="modal-header">
          <div class="modal-title-group">
            <h3>{{ isEditing ? 'Edit Syllabus' : 'Add New Syllabus' }}</h3>
            <p class="modal-subtitle">
              {{ isEditing ? 'Update the syllabus details' : 'Fill in the syllabus details' }}
            </p>
          </div>
          <button class="close-btn" @click="closeModal">✕</button>
        </div>
        
        <div class="modal-body">
          <form @submit.prevent="saveItem" class="syllabus-form">
            <div class="form-row">
              <div class="form-group">
                <label for="course">Course Name *</label>
                <input 
                  type="text" 
                  id="course" 
                  v-model="formData.course" 
                  required
                  placeholder="Enter course name"
                  class="form-input"
                >
              </div>
              
              <div class="form-group">
                <label for="courseCode">Course Code</label>
                <input 
                  type="text" 
                  id="courseCode" 
                  v-model="formData.courseCode" 
                  placeholder="e.g., CS101"
                  class="form-input"
                >
              </div>
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label for="instructor">Instructor *</label>
                <input 
                  type="text" 
                  id="instructor" 
                  v-model="formData.instructor" 
                  required
                  placeholder="Enter instructor name"
                  class="form-input"
                >
              </div>
              
              <div class="form-group">
                <label for="format">File Format</label>
                <select id="format" v-model="formData.format" class="form-select">
                  <option value="pdf">PDF</option>
                  <option value="doc">Word Document</option>
                  <option value="excel">Excel Sheet</option>
                  <option value="other">Other</option>
                </select>
              </div>
            </div>
            
            <div class="form-group">
              <label for="fileURL">File URL *</label>
              <input 
                type="url" 
                id="fileURL" 
                v-model="formData.fileURL" 
                required
                placeholder="https://example.com/syllabus.pdf"
                class="form-input"
              >
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label for="fileSize">File Size (in bytes)</label>
                <input 
                  type="number" 
                  id="fileSize" 
                  v-model="formData.fileSize" 
                  placeholder="e.g., 2457600"
                  class="form-input"
                  min="0"
                >
              </div>
              
              <div class="form-group">
                <label for="uploadDate">Upload Date</label>
                <input 
                  type="date" 
                  id="uploadDate" 
                  v-model="formData.uploadDate" 
                  class="form-input"
                >
              </div>
            </div>
            
            <div class="form-group">
              <label for="description">Description</label>
              <textarea 
                id="description" 
                v-model="formData.description" 
                rows="3"
                placeholder="Enter course description..."
                class="form-textarea"
              ></textarea>
            </div>
            
            <div class="form-preview" v-if="formData.fileURL">
              <div class="preview-info">
                <span class="preview-icon">{{ getFileIcon(formData.fileURL) }}</span>
                <div>
                  <div class="preview-filename">{{ getFileName(formData.fileURL) }}</div>
                  <div class="preview-format">
                    {{ getFormatText(formData.format || getFileFormat(formData.fileURL)) }} • 
                    {{ formData.fileSize ? formatFileSize(formData.fileSize) : 'Unknown size' }}
                  </div>
                </div>
              </div>
            </div>
          </form>
        </div>
        
        <div class="modal-footer">
          <div class="modal-actions">
            <button class="btn btn-secondary" @click="closeModal" type="button">
              Cancel
            </button>
            <button class="btn delete-btn" @click="confirmDelete(formData)" v-if="isEditing" type="button">
              Delete
            </button>
            <button class="btn save-btn" @click="saveItem" :disabled="saving">
              {{ saving ? 'Saving...' : (isEditing ? 'Update Syllabus' : 'Add Syllabus') }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Confirmation Modal -->
    <div v-if="showConfirmModal" class="modal-overlay" @click="cancelDelete">
      <div class="modal-content confirm-modal" @click.stop>
        <div class="modal-header">
          <div class="modal-title-group">
            <h3>Confirm Delete</h3>
            <p class="modal-subtitle">Are you sure you want to delete this syllabus?</p>
          </div>
        </div>
        
        <div class="modal-body">
          <div class="delete-preview">
            <div class="delete-icon">🗑️</div>
            <div class="delete-info">
              <h4>{{ itemToDelete.course }}</h4>
              <p v-if="itemToDelete.courseCode">{{ itemToDelete.courseCode }}</p>
              <p v-if="itemToDelete.instructor">By: {{ itemToDelete.instructor }}</p>
              <p class="delete-warning">This action cannot be undone.</p>
            </div>
          </div>
        </div>
        
        <div class="modal-footer">
          <div class="modal-actions">
            <button class="btn btn-secondary" @click="cancelDelete" type="button">
              Cancel
            </button>
            <button class="btn delete-confirm-btn" @click="deleteItem" :disabled="deleting">
              {{ deleting ? 'Deleting...' : 'Yes, Delete' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="toast.type">
      <span class="toast-icon">{{ toast.icon }}</span>
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="toast.show = false">✕</button>
    </div>
  </div>
</template>

<script>
import { getSyllabusList } from "../../services/syllabusService";

export default {
  name: 'SyllabusList',
  data() {
    return {
      syllabusList: [],
      loading: true,
      searchQuery: '',
      selectedFormat: 'all',
      sortBy: 'course',
      sortDirection: 'asc',
      viewMode: 'grid', // 'grid' or 'list'
      hoveredCard: null,
      previewItem: null,
      favorites: JSON.parse(localStorage.getItem('syllabusFavorites')) || [],
      toast: {
        show: false,
        message: '',
        type: 'info', // 'info', 'success', 'error'
        icon: 'ℹ️'
      },
      // Add/Edit Modal Data
      showModal: false,
      isEditing: false,
      saving: false,
      formData: {
        id: '',
        course: '',
        courseCode: '',
        instructor: '',
        fileURL: '',
        fileSize: '',
        uploadDate: '',
        format: 'pdf',
        description: ''
      },
      // Delete Confirmation Modal Data
      showConfirmModal: false,
      itemToDelete: null,
      deleting: false
    };
  },
  computed: {
    filteredSyllabi() {
      let filtered = [...this.syllabusList];

      // Apply search filter
      if (this.searchQuery) {
        const query = this.searchQuery.toLowerCase();
        filtered = filtered.filter(item => 
          item.course?.toLowerCase().includes(query) ||
          item.courseCode?.toLowerCase().includes(query) ||
          item.instructor?.toLowerCase().includes(query) ||
          item.description?.toLowerCase().includes(query)
        );
      }

      // Apply format filter
      if (this.selectedFormat !== 'all') {
        filtered = filtered.filter(item => {
          const format = item.format || this.getFileFormat(item.fileURL);
          return format === this.selectedFormat;
        });
      }

      // Apply sorting
      filtered.sort((a, b) => {
        let aValue, bValue;

        switch (this.sortBy) {
          case 'course':
            aValue = a.course || '';
            bValue = b.course || '';
            break;
          case 'instructor':
            aValue = a.instructor || '';
            bValue = b.instructor || '';
            break;
          case 'format':
            aValue = a.format || this.getFileFormat(a.fileURL);
            bValue = b.format || this.getFileFormat(b.fileURL);
            break;
          case 'date':
            aValue = new Date(a.uploadDate || 0);
            bValue = new Date(b.uploadDate || 0);
            break;
          case 'size':
            aValue = a.fileSize || 0;
            bValue = b.fileSize || 0;
            break;
          default:
            aValue = a.course || '';
            bValue = b.course || '';
        }

        if (typeof aValue === 'string') {
          aValue = aValue.toLowerCase();
          bValue = bValue.toLowerCase();
        }

        if (aValue < bValue) return this.sortDirection === 'asc' ? -1 : 1;
        if (aValue > bValue) return this.sortDirection === 'asc' ? 1 : -1;
        return 0;
      });

      // Add favorite status
      return filtered.map(item => ({
        ...item,
        isFavorited: this.favorites.includes(item.id)
      }));
    }
  },
  async created() {
    await this.loadSyllabi();
  },
  methods: {
    async loadSyllabi() {
      this.loading = true;
      try {
        this.syllabusList = await getSyllabusList();
        // Add sample data for demo if needed
        if (this.syllabusList.length === 0) {
          this.syllabusList = this.getSampleData();
        }
      } catch (error) {
        console.error('Error loading syllabi:', error);
        this.showToast('Failed to load syllabi. Please try again.', 'error');
        this.syllabusList = this.getSampleData();
      } finally {
        this.loading = false;
      }
    },

    getSampleData() {
      return [
        {
          id: '1',
          course: 'Computer Science Fundamentals',
          courseCode: 'CS101',
          instructor: 'Dr. Sarah Johnson',
          fileURL: 'https://example.com/syllabus.pdf',
          fileSize: 2457600,
          uploadDate: '2024-01-15',
          format: 'pdf',
          description: 'Introduction to computer science concepts and programming basics.'
        },
        {
          id: '2',
          course: 'Advanced Mathematics',
          courseCode: 'MATH202',
          instructor: 'Prof. Michael Chen',
          fileURL: 'https://example.com/math_syllabus.docx',
          fileSize: 1835008,
          uploadDate: '2024-01-14',
          format: 'doc'
        },
        {
          id: '3',
          course: 'Business Statistics',
          courseCode: 'BUS305',
          instructor: 'Dr. Emily Williams',
          fileURL: 'https://example.com/stats_schedule.xlsx',
          fileSize: 3145728,
          uploadDate: '2024-01-13',
          format: 'excel'
        }
      ];
    },

    // File Methods
    getFileFormat(fileURL) {
      if (!fileURL) return 'other';
      const extension = fileURL.split('.').pop().toLowerCase();
      if (extension === 'pdf') return 'pdf';
      if (['doc', 'docx'].includes(extension)) return 'doc';
      if (['xls', 'xlsx', 'csv'].includes(extension)) return 'excel';
      if (['jpg', 'jpeg', 'png', 'gif'].includes(extension)) return 'image';
      return 'other';
    },

    getFormatClass(format) {
      const formatMap = {
        pdf: 'format-pdf',
        doc: 'format-doc',
        excel: 'format-excel',
        image: 'format-image',
        other: 'format-other'
      };
      return formatMap[format] || 'format-other';
    },

    getFormatText(format) {
      const formatText = {
        pdf: 'PDF',
        doc: 'DOC',
        excel: 'EXCEL',
        image: 'IMAGE',
        other: 'FILE'
      };
      return formatText[format] || 'FILE';
    },

    getFileIcon(fileURL) {
      const format = this.getFileFormat(fileURL);
      const icons = {
        pdf: '📄',
        doc: '📝',
        excel: '📊',
        image: '🖼️',
        other: '📁'
      };
      return icons[format] || '📁';
    },

    getFileIconClass(fileURL) {
      const format = this.getFileFormat(fileURL);
      return `icon-${format}`;
    },

    getFileName(fileURL) {
      if (!fileURL) return 'Unknown file';
      return fileURL.split('/').pop().split('?')[0];
    },

    formatFileSize(bytes) {
      if (!bytes) return 'Unknown size';
      if (bytes === 0) return '0 Bytes';
      const k = 1024;
      const sizes = ['Bytes', 'KB', 'MB', 'GB'];
      const i = Math.floor(Math.log(bytes) / Math.log(k));
      return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
    },

    formatDate(dateString) {
      if (!dateString) return 'N/A';
      const date = new Date(dateString);
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      });
    },

    truncateText(text, maxLength) {
      if (!text) return '';
      if (text.length <= maxLength) return text;
      return text.substring(0, maxLength) + '...';
    },

    canPreview(fileURL) {
      return this.isPdfFile(fileURL);
    },

    isPdfFile(fileURL) {
      return this.getFileFormat(fileURL) === 'pdf';
    },

    // UI Methods
    handleSearch() {
      // Debounce could be added here for performance
    },

    clearSearch() {
      this.searchQuery = '';
    },

    toggleViewMode() {
      this.viewMode = this.viewMode === 'grid' ? 'list' : 'grid';
    },

    sortTable(column) {
      if (this.sortBy === column) {
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
      } else {
        this.sortBy = column;
        this.sortDirection = 'asc';
      }
    },

    toggleFavorite(item) {
      const index = this.favorites.indexOf(item.id);
      if (index === -1) {
        this.favorites.push(item.id);
        this.showToast('Added to favorites', 'success', '⭐');
      } else {
        this.favorites.splice(index, 1);
        this.showToast('Removed from favorites', 'info', '☆');
      }
      localStorage.setItem('syllabusFavorites', JSON.stringify(this.favorites));
    },

    previewFile(item) {
      if (this.canPreview(item.fileURL)) {
        this.previewItem = item;
      } else {
        this.showToast('Preview not available for this file type', 'error', '⚠️');
      }
    },

    closePreview() {
      this.previewItem = null;
    },

    async downloadFile(item) {
      try {
        const link = document.createElement('a');
        link.href = item.fileURL;
        link.download = this.getFileName(item.fileURL);
        link.target = '_blank';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        
        this.showToast('Download started', 'success', '⬇️');
        
        // Track download analytics (optional)
        this.trackDownload(item);
      } catch (error) {
        console.error('Download error:', error);
        this.showToast('Download failed. Please try again.', 'error', '❌');
      }
    },

    shareFile(item) {
      if (navigator.share) {
        navigator.share({
          title: item.course,
          text: `Check out the syllabus for ${item.course}`,
          url: item.fileURL
        }).catch(console.error);
      } else {
        navigator.clipboard.writeText(item.fileURL).then(() => {
          this.showToast('Link copied to clipboard', 'success', '📋');
        });
      }
    },

    copyLink(item) {
      navigator.clipboard.writeText(item.fileURL).then(() => {
        this.showToast('Link copied to clipboard', 'success', '📋');
      });
    },

    showDetails(item) {
      this.showToast(`Details for ${item.course}`, 'info', 'ℹ️');
    },

    trackDownload(item) {
      // Optional: Send analytics or track downloads
      console.log('Download tracked:', item.course);
    },

    // Add/Edit Methods
    showAddModal() {
      this.resetForm();
      this.isEditing = false;
      this.showModal = true;
    },

    editItem(item) {
      this.formData = {
        id: item.id,
        course: item.course || '',
        courseCode: item.courseCode || '',
        instructor: item.instructor || '',
        fileURL: item.fileURL || '',
        fileSize: item.fileSize || '',
        uploadDate: item.uploadDate || '',
        format: item.format || 'pdf',
        description: item.description || ''
      };
      this.isEditing = true;
      this.showModal = true;
    },

    closeModal() {
      this.showModal = false;
      this.resetForm();
    },

    resetForm() {
      this.formData = {
        id: '',
        course: '',
        courseCode: '',
        instructor: '',
        fileURL: '',
        fileSize: '',
        uploadDate: '',
        format: 'pdf',
        description: ''
      };
    },

    async saveItem() {
      if (!this.validateForm()) return;
      
      this.saving = true;
      
      try {
        // Simulate API call delay
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        if (this.isEditing) {
          // Update existing item
          const index = this.syllabusList.findIndex(item => item.id === this.formData.id);
          if (index !== -1) {
            this.syllabusList[index] = { ...this.formData };
          }
          this.showToast('Syllabus updated successfully!', 'success', '✅');
        } else {
          // Add new item
          const newItem = {
            ...this.formData,
            id: Date.now().toString(), // Generate unique ID
            uploadDate: this.formData.uploadDate || new Date().toISOString().split('T')[0]
          };
          this.syllabusList.unshift(newItem);
          this.showToast('Syllabus added successfully!', 'success', '✅');
        }
        
        this.closeModal();
      } catch (error) {
        console.error('Error saving syllabus:', error);
        this.showToast('Failed to save syllabus. Please try again.', 'error', '❌');
      } finally {
        this.saving = false;
      }
    },

    validateForm() {
      if (!this.formData.course.trim()) {
        this.showToast('Course name is required', 'error', '⚠️');
        return false;
      }
      if (!this.formData.instructor.trim()) {
        this.showToast('Instructor name is required', 'error', '⚠️');
        return false;
      }
      if (!this.formData.fileURL.trim()) {
        this.showToast('File URL is required', 'error', '⚠️');
        return false;
      }
      return true;
    },

    // Delete Methods
    confirmDelete(item) {
      this.itemToDelete = item;
      this.showConfirmModal = true;
    },

    cancelDelete() {
      this.showConfirmModal = false;
      this.itemToDelete = null;
    },

    async deleteItem() {
      this.deleting = true;
      
      try {
        // Simulate API call delay
        await new Promise(resolve => setTimeout(resolve, 800));
        
        // Remove from syllabus list
        this.syllabusList = this.syllabusList.filter(item => item.id !== this.itemToDelete.id);
        
        // Remove from favorites if exists
        const favIndex = this.favorites.indexOf(this.itemToDelete.id);
        if (favIndex !== -1) {
          this.favorites.splice(favIndex, 1);
          localStorage.setItem('syllabusFavorites', JSON.stringify(this.favorites));
        }
        
        this.showToast('Syllabus deleted successfully!', 'success', '✅');
        this.cancelDelete();
        
        // Close edit modal if open
        if (this.showModal) {
          this.closeModal();
        }
      } catch (error) {
        console.error('Error deleting syllabus:', error);
        this.showToast('Failed to delete syllabus. Please try again.', 'error', '❌');
      } finally {
        this.deleting = false;
      }
    },

    // Toast Notification
    showToast(message, type = 'info', icon = 'ℹ️') {
      this.toast = { show: true, message, type, icon };
      setTimeout(() => {
        this.toast.show = false;
      }, 3000);
    }
  }
};
</script>

<style scoped>
.syllabus-list-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
}

/* Header Styles */
.header-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
  background: white;
  padding: 24px;
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.title-group {
  display: flex;
  align-items: center;
  gap: 20px;
}

.icon-wrapper {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.icon {
  font-size: 32px;
  color: white;
}

.page-title {
  font-size: 32px;
  color: #2c3e50;
  margin: 0 0 4px 0;
  font-weight: 700;
}

.page-subtitle {
  color: #7f8c8d;
  font-size: 16px;
  margin: 0;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 20px;
}

.stats-card {
  display: flex;
  align-items: center;
  gap: 12px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 16px 24px;
  border-radius: 12px;
  color: white;
}

.stats-icon {
  font-size: 24px;
}

.stats-content {
  display: flex;
  flex-direction: column;
}

.stats-number {
  font-size: 24px;
  font-weight: 700;
}

.stats-label {
  font-size: 12px;
  opacity: 0.9;
}

.add-btn {
  background: #27ae60;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 8px;
  white-space: nowrap;
}

.add-btn:hover {
  background: #219653;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(39, 174, 96, 0.3);
}

/* Controls Section */
.controls-section {
  background: white;
  padding: 20px 24px;
  border-radius: 16px;
  margin-bottom: 24px;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);
}

.search-box {
  position: relative;
  margin-bottom: 20px;
}

.search-icon {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 20px;
  color: #7f8c8d;
}

.search-input {
  width: 90%;
  padding: 16px 16px 16px 48px;
  border: 2px solid #e0e0e0;
  border-radius: 12px;
  font-size: 16px;
  transition: all 0.3s;
  background: #f8f9fa;
}

.search-input:focus {
  outline: none;
  border-color: #667eea;
  background: white;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.clear-search-btn {
  position: absolute;
  right: 16px;
  top: 50%;
  transform: translateY(-50%);
  background: #e0e0e0;
  border: none;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 14px;
  color: #666;
}

.filter-group {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.filter-select {
  padding: 12px 16px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  background: white;
  cursor: pointer;
  min-width: 150px;
}

.filter-select:focus {
  outline: none;
  border-color: #667eea;
}

.view-toggle-btn {
  padding: 12px 24px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 8px;
}

.view-toggle-btn:hover {
  background: #5a6fd8;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

/* Loading State */
.loading-state {
  text-align: center;
  padding: 80px 20px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);
}

.spinner {
  width: 60px;
  height: 60px;
  border: 4px solid #f0f0f0;
  border-top-color: #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.loading-text {
  font-size: 18px;
  color: #2c3e50;
  margin-bottom: 8px;
  font-weight: 600;
}

.loading-subtext {
  color: #7f8c8d;
  font-size: 14px;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 80px 20px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);
}

.empty-icon {
  font-size: 72px;
  margin-bottom: 24px;
  opacity: 0.5;
}

.empty-title {
  font-size: 24px;
  color: #2c3e50;
  margin-bottom: 12px;
}

.empty-message {
  color: #7f8c8d;
  font-size: 16px;
  margin-bottom: 24px;
  max-width: 500px;
  margin-left: auto;
  margin-right: auto;
}

/* Grid View */
.syllabus-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 24px;
  margin-bottom: 40px;
}

.syllabus-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);
  transition: all 0.3s;
  position: relative;
  border: 1px solid #eaeaea;
}

.syllabus-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.12);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background: linear-gradient(135deg, #667eea15 0%, #764ba215 100%);
  border-bottom: 1px solid #eaeaea;
}

.format-badge {
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 700;
  color: white;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.format-pdf {
  background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
}

.format-doc {
  background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
}

.format-excel {
  background: linear-gradient(135deg, #27ae60 0%, #219653 100%);
}

.format-image {
  background: linear-gradient(135deg, #9b59b6 0%, #8e44ad 100%);
}

.format-other {
  background: linear-gradient(135deg, #95a5a6 0%, #7f8c8d 100%);
}

.card-actions {
  display: flex;
  gap: 8px;
}

.icon-btn {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: none;
  background: white;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 16px;
  transition: all 0.2s;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.edit-btn {
  color: #3498db;
}

.edit-btn:hover {
  background: #e3f2fd;
  transform: scale(1.1);
}

.delete-btn {
  color: #e74c3c;
}

.delete-btn:hover {
  background: #ffebee;
  transform: scale(1.1);
}

.favorite-btn:hover {
  background: #fff3cd;
  color: #ffc107;
}

.favorite-btn.favorited {
  background: #fff3cd;
  color: #ffc107;
}

.card-body {
  padding: 20px;
}

.course-info {
  margin-bottom: 20px;
}

.course-title {
  font-size: 20px;
  color: #2c3e50;
  margin: 0 0 8px 0;
  font-weight: 600;
  line-height: 1.4;
}

.course-code {
  color: #667eea;
  font-size: 14px;
  font-weight: 500;
  margin: 0 0 12px 0;
}

.instructor {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #7f8c8d;
  font-size: 14px;
  margin: 0;
}

.instructor-icon {
  font-size: 16px;
}

.file-info {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 12px;
  margin-bottom: 16px;
}

.file-icon {
  font-size: 32px;
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.icon-pdf {
  background: #ffebee;
  color: #e74c3c;
}

.icon-doc {
  background: #e3f2fd;
  color: #3498db;
}

.icon-excel {
  background: #e8f5e9;
  color: #27ae60;
}

.icon-image {
  background: #f3e5f5;
  color: #9b59b6;
}

.icon-other {
  background: #eceff1;
  color: #607d8b;
}

.file-details {
  flex: 1;
  min-width: 0;
}

.file-name {
  font-weight: 600;
  color: #2c3e50;
  margin: 0 0 6px 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.file-meta {
  display: flex;
  gap: 12px;
}

.file-size, .file-date {
  font-size: 12px;
  color: #7f8c8d;
  background: white;
  padding: 4px 8px;
  border-radius: 4px;
}

.course-description {
  color: #5d6d7e;
  font-size: 14px;
  line-height: 1.6;
  padding: 12px 0;
  border-top: 1px solid #eaeaea;
}

.card-footer {
  display: flex;
  gap: 12px;
  padding: 20px;
  background: #f8f9fa;
  border-top: 1px solid #eaeaea;
}

.btn {
  flex: 1;
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
  gap: 8px;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.preview-btn {
  background: #3498db;
  color: white;
}

.preview-btn:hover:not(:disabled) {
  background: #2980b9;
  transform: translateY(-2px);
}

.download-btn {
  background: #27ae60;
  color: white;
}

.download-btn:hover {
  background: #219653;
  transform: translateY(-2px);
}

.btn-icon {
  font-size: 16px;
}

.card-hover-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(102, 126, 234, 0.95);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s;
}

.syllabus-card:hover .card-hover-overlay {
  opacity: 1;
}

.hover-actions {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
  justify-content: center;
}

.hover-action-btn {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: white;
  border: none;
  font-size: 20px;
  cursor: pointer;
  transition: all 0.3s;
}

.delete-hover-btn {
  color: #e74c3c;
}

.hover-action-btn:hover {
  transform: scale(1.1);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

/* List View */
.syllabus-table-container {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);
  margin-bottom: 40px;
}

.table-wrapper {
  overflow-x: auto;
}

.syllabus-table {
  width: 100%;
  border-collapse: collapse;
}

.syllabus-table th {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-weight: 600;
  text-align: left;
  padding: 16px 20px;
  font-size: 14px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.syllabus-table td {
  padding: 16px 20px;
  border-bottom: 1px solid #eaeaea;
}

.syllabus-table tr:hover {
  background: #f8f9fa;
}

.syllabus-table tr:last-child td {
  border-bottom: none;
}

.sortable-header {
  cursor: pointer;
  user-select: none;
  position: relative;
  padding-right: 30px !important;
}

.sortable-header:hover {
  background: rgba(255, 255, 255, 0.1);
}

.sort-icon {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 12px;
}

.course-cell-content {
  display: flex;
  align-items: center;
  gap: 12px;
}

.course-icon {
  font-size: 20px;
  color: #667eea;
}

.course-name {
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 4px;
}

.course-code-small {
  font-size: 12px;
  color: #667eea;
  font-weight: 500;
}

.instructor-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}

.instructor-icon-small {
  font-size: 16px;
  opacity: 0.7;
}

.file-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.file-icon-small {
  font-size: 20px;
  width: 40px;
  height: 40px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.file-info-small {
  min-width: 0;
}

.file-name-small {
  font-weight: 500;
  color: #2c3e50;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 200px;
}

.format-tag {
  padding: 6px 12px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 700;
  color: white;
  display: inline-block;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.date-cell {
  font-size: 14px;
  color: #5d6d7e;
  font-weight: 500;
}

.size-badge {
  background: #e3f2fd;
  color: #1976d2;
  padding: 6px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.action-buttons {
  display: flex;
  gap: 8px;
}

.action-btn {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  border: none;
  background: #f8f9fa;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 16px;
  transition: all 0.2s;
}

.action-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.action-btn.edit-btn:hover {
  background: #e3f2fd;
  color: #1976d2;
}

.action-btn.delete-btn:hover {
  background: #ffebee;
  color: #e74c3c;
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.75);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal-content {
  background: white;
  border-radius: 20px;
  width: 90%;
  max-width: 1000px;
  max-height: 90vh;
  overflow: hidden;
  animation: slideUp 0.4s ease;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.modal-title-group h3 {
  margin: 0 0 4px 0;
  font-size: 24px;
  color: white;
}

.modal-subtitle {
  margin: 0;
  opacity: 0.9;
  font-size: 14px;
}

.close-btn {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 20px;
  color: white;
  transition: all 0.2s;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.3);
}

.modal-body {
  height: 60vh;
  overflow-y: auto;
  padding: 24px;
}

.edit-modal .modal-body {
  height: auto;
  max-height: 60vh;
}

/* Form Styles */
.syllabus-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

@media (max-width: 768px) {
  .form-row {
    grid-template-columns: 1fr;
  }
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  font-weight: 600;
  color: #2c3e50;
  font-size: 14px;
}

.form-group label::after {
  content: '*';
  color: #e74c3c;
  margin-left: 4px;
  opacity: 0.7;
}

.form-group label[for="courseCode"]::after,
.form-group label[for="fileSize"]::after,
.form-group label[for="uploadDate"]::after,
.form-group label[for="description"]::after,
.form-group label[for="format"]::after {
  content: '';
  display: none;
}

.form-input, .form-select, .form-textarea {
  padding: 12px 16px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 14px;
  font-family: inherit;
  transition: all 0.3s;
  background: white;
}

.form-input:focus, .form-select:focus, .form-textarea:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-textarea {
  resize: vertical;
  min-height: 80px;
}

.form-preview {
  background: #f8f9fa;
  padding: 16px;
  border-radius: 12px;
  border: 2px dashed #e0e0e0;
}

.preview-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.preview-icon {
  font-size: 32px;
  width: 56px;
  height: 56px;
  border-radius: 12px;
  background: #e3f2fd;
  color: #3498db;
  display: flex;
  align-items: center;
  justify-content: center;
}

.preview-filename {
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 4px;
}

.preview-format {
  font-size: 12px;
  color: #7f8c8d;
}

.save-btn {
  background: #27ae60;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.save-btn:hover:not(:disabled) {
  background: #219653;
  transform: translateY(-2px);
}

.save-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Delete Confirmation Modal */
.confirm-modal {
  max-width: 500px;
}

.delete-preview {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 20px;
  background: #fff8f8;
  border-radius: 12px;
  border: 2px solid #ffebee;
}

.delete-icon {
  font-size: 48px;
  color: #e74c3c;
}

.delete-info h4 {
  margin: 0 0 8px 0;
  color: #2c3e50;
}

.delete-info p {
  margin: 4px 0;
  color: #7f8c8d;
}

.delete-warning {
  color: #e74c3c !important;
  font-weight: 600;
  margin-top: 12px !important;
  padding-top: 12px;
  border-top: 1px solid #ffcdd2;
}

.delete-confirm-btn {
  background: #e74c3c;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.delete-confirm-btn:hover:not(:disabled) {
  background: #c0392b;
  transform: translateY(-2px);
}

.delete-confirm-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Modal Footer */
.modal-footer {
  padding: 24px;
  border-top: 1px solid #eaeaea;
  background: #f8f9fa;
}

.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}

.btn-secondary {
  background: #95a5a6;
  color: white;
}

.btn-secondary:hover {
  background: #7f8c8d;
  transform: translateY(-2px);
}

/* Toast Notification */
.toast-notification {
  position: fixed;
  bottom: 24px;
  right: 24px;
  background: white;
  padding: 16px 24px;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
  display: flex;
  align-items: center;
  gap: 12px;
  z-index: 1001;
  animation: slideInRight 0.3s ease;
  max-width: 400px;
  border-left: 4px solid #667eea;
}

@keyframes slideInRight {
  from {
    opacity: 0;
    transform: translateX(100%);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.toast-notification.success {
  border-left-color: #27ae60;
}

.toast-notification.error {
  border-left-color: #e74c3c;
}

.toast-notification.info {
  border-left-color: #3498db;
}

.toast-icon {
  font-size: 20px;
}

.toast-message {
  flex: 1;
  font-weight: 500;
  color: #2c3e50;
}

.toast-close {
  background: none;
  border: none;
  font-size: 16px;
  cursor: pointer;
  color: #7f8c8d;
  padding: 4px;
  border-radius: 4px;
}

.toast-close:hover {
  background: #f0f0f0;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .syllabus-grid {
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  }
}

@media (max-width: 768px) {
  .syllabus-list-container {
    padding: 16px;
  }
  
  .header-section {
    flex-direction: column;
    gap: 20px;
    text-align: center;
  }
  
  .header-actions {
    flex-direction: column;
    width: 100%;
  }
  
  .stats-card {
    width: 100%;
    justify-content: center;
  }
  
  .add-btn {
    width: 100%;
  }
  
  .title-group {
    flex-direction: column;
    text-align: center;
  }
  
  .syllabus-grid {
    grid-template-columns: 1fr;
  }
  
  .filter-group {
    flex-direction: column;
  }
  
  .filter-select, .view-toggle-btn {
    width: 100%;
  }
  
  .syllabus-table {
    min-width: 800px;
  }
  
  .card-footer {
    flex-direction: column;
  }
  
  .modal-content {
    width: 95%;
    margin: 10px;
  }
  
  .form-row {
    grid-template-columns: 1fr;
  }
  
  .modal-actions {
    flex-direction: column;
  }
  
  .modal-actions .btn {
    width: 100%;
  }
  
  .delete-preview {
    flex-direction: column;
    text-align: center;
  }
  
  .hover-actions {
    gap: 12px;
  }
  
  .hover-action-btn {
    width: 40px;
    height: 40px;
    font-size: 18px;
  }
}

@media (max-width: 480px) {
  .page-title {
    font-size: 24px;
  }
  
  .search-input {
    padding: 12px 12px 12px 40px;
  }
  
  .syllabus-card {
    margin: 0 8px;
  }
  
  .action-buttons {
    flex-wrap: wrap;
    justify-content: center;
  }
  
  .action-btn {
    width: 32px;
    height: 32px;
    font-size: 14px;
  }
  
  .toast-notification {
    left: 16px;
    right: 16px;
    bottom: 16px;
    max-width: none;
  }
}
</style>