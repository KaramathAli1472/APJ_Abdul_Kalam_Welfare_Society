// MobileAppIDCardScreen.js
import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, Image, ScrollView, TouchableOpacity } from 'react-native';
import QRCode from 'react-native-qrcode-svg';
import { getFirestore, doc, getDoc } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';

const MobileAppIDCardScreen = () => {
  const [idCardData, setIdCardData] = useState(null);
  const [loading, setLoading] = useState(true);
  const auth = getAuth();
  const db = getFirestore();

  useEffect(() => {
    loadIDCard();
  }, []);

  const loadIDCard = async () => {
    try {
      const userId = auth.currentUser?.uid;
      if (!userId) return;

      const idCardRef = doc(db, "student_id_cards", userId);
      const idCardSnap = await getDoc(idCardRef);

      if (idCardSnap.exists()) {
        setIdCardSnap.data());
      }
    } catch (error) {
      console.error("Error loading ID Card:", error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <Text>Loading your ID Card...</Text>
      </View>
    );
  }

  if (!idCardData) {
    return (
      <View style={styles.emptyContainer}>
        <Text style={styles.emptyTitle}>No ID Card Available</Text>
        <Text style={styles.emptyText}>
          Your ID Card has not been generated yet.
          Please contact your school administrator.
        </Text>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container}>
      {/* ID Card Design */}
      <View style={styles.idCard}>
        {/* Header */}
        <View style={styles.header}>
          <View style={styles.logoContainer}>
            <Text style={styles.logo}>🏫</Text>
          </View>
          <View style={styles.schoolInfo}>
            <Text style={styles.schoolName}>GLOBAL EDUCATION INSTITUTE</Text>
            <Text style={styles.schoolTagline}>Shaping Future Leaders</Text>
            <Text style={styles.idCardTitle}>STUDENT IDENTITY CARD</Text>
          </View>
        </View>

        {/* Student Photo & Info */}
        <View style={styles.body}>
          <View style={styles.photoSection}>
            <View style={styles.photoFrame}>
              <View style={styles.photoPlaceholder}>
                <Text style={styles.initials}>
                  {getInitials(idCardData.studentName)}
                </Text>
              </View>
            </View>
            <View style={styles.validity}>
              <Text style={styles.validLabel}>VALID UNTIL</Text>
              <Text style={styles.validDate}>
                {formatDate(idCardData.validUntil)}
              </Text>
            </View>
          </View>

          <View style={styles.detailsSection}>
            <DetailRow label="NAME" value={idCardData.studentName} />
            <DetailRow label="GRADE" value={idCardData.studentGrade} />
            <DetailRow label="STUDENT ID" value={idCardData.studentId} isIdNumber />
            <DetailRow label="EMAIL" value={idCardData.studentEmail} />
            <DetailRow label="ISSUE DATE" value={formatDate(idCardData.issueDate)} />
          </View>
        </View>

        {/* Footer */}
        <View style={styles.footer}>
          <View style={styles.barcodeSection}>
            <QRCode
              value={idCardData.qrCodeData}
              size={120}
              color="#000"
              backgroundColor="#fff"
            />
            <Text style={styles.barcodeNumber}>{idCardData.cardNumber}</Text>
          </View>
          
          <View style={styles.signatureSection}>
            <Text style={styles.signatureLabel}>AUTHORIZED SIGNATURE</Text>
            <View style={styles.signatureLine} />
            <Text style={styles.principalName}>Principal</Text>
          </View>
        </View>
      </View>

      {/* Action Buttons */}
      <View style={styles.actionButtons}>
        <TouchableOpacity style={styles.downloadButton}>
          <Text style={styles.buttonText}>Download ID Card</Text>
        </TouchableOpacity>
        
        <TouchableOpacity style={styles.shareButton}>
          <Text style={styles.buttonText}>Share ID Card</Text>
        </TouchableOpacity>
        
        <TouchableOpacity style={styles.refreshButton}>
          <Text style={styles.buttonText}>Refresh QR Code</Text>
        </TouchableOpacity>
      </View>

      {/* Card Info */}
      <View style={styles.cardInfo}>
        <InfoItem title="Card Status" value={idCardData.status.toUpperCase()} />
        <InfoItem title="Last Updated" value={formatDate(idCardData.lastUpdated)} />
        <InfoItem title="Views" value={idCardData.viewCount || 0} />
        <InfoItem title="Downloads" value={idCardData.downloadCount || 0} />
      </View>
    </ScrollView>
  );
};

const DetailRow = ({ label, value, isIdNumber = false }) => (
  <View style={styles.detailRow}>
    <Text style={styles.detailLabel}>{label}:</Text>
    <Text style={[styles.detailValue, isIdNumber && styles.idNumber]}>
      {value}
    </Text>
  </View>
);

const InfoItem = ({ title, value }) => (
  <View style={styles.infoItem}>
    <Text style={styles.infoTitle}>{title}</Text>
    <Text style={styles.infoValue}>{value}</Text>
  </View>
);

// Helper functions
const getInitials = (name) => {
  if (!name) return '??';
  return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
};

const formatDate = (dateString) => {
  if (!dateString) return 'N/A';
  const date = new Date(dateString);
  return date.toLocaleDateString('en-US', {
    month: 'short',
    year: 'numeric'
  }).toUpperCase();
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8fafc',
    padding: 16,
  },
  idCard: {
    backgroundColor: '#1e293b',
    borderRadius: 20,
    padding: 24,
    marginBottom: 20,
    borderWidth: 4,
    borderColor: '#fff',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.3,
    shadowRadius: 20,
    elevation: 10,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 24,
    borderBottomWidth: 2,
    borderBottomColor: 'rgba(255,255,255,0.2)',
    paddingBottom: 16,
  },
  logoContainer: {
    width: 70,
    height: 70,
    backgroundColor: '#fff',
    borderRadius: 35,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 16,
  },
  logo: {
    fontSize: 32,
  },
  schoolName: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '900',
    letterSpacing: 0.5,
  },
  schoolTagline: {
    color: '#cbd5e1',
    fontSize: 12,
    marginTop: 4,
  },
  idCardTitle: {
    color: '#fbbf24',
    fontSize: 14,
    fontWeight: '700',
    marginTop: 8,
    letterSpacing: 2,
  },
  body: {
    flexDirection: 'row',
    marginBottom: 24,
  },
  photoSection: {
    alignItems: 'center',
    marginRight: 24,
  },
  photoFrame: {
    width: 120,
    height: 140,
    backgroundColor: '#fff',
    borderRadius: 12,
    borderWidth: 4,
    borderColor: '#fbbf24',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 16,
  },
  photoPlaceholder: {
    width: 100,
    height: 120,
    backgroundColor: '#4F46E5',
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  initials: {
    color: '#fff',
    fontSize: 32,
    fontWeight: '900',
  },
  validity: {
    alignItems: 'center',
    padding: 12,
    backgroundColor: 'rgba(255,255,255,0.1)',
    borderRadius: 8,
    borderWidth: 2,
    borderColor: 'rgba(255,255,255,0.2)',
  },
  validLabel: {
    color: '#cbd5e1',
    fontSize: 10,
    fontWeight: '700',
    letterSpacing: 1,
  },
  validDate: {
    color: '#fbbf24',
    fontSize: 16,
    fontWeight: '900',
    marginTop: 4,
  },
  detailsSection: {
    flex: 1,
  },
  detailRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255,255,255,0.1)',
  },
  detailLabel: {
    color: '#cbd5e1',
    fontSize: 12,
    fontWeight: '700',
    width: 100,
    letterSpacing: 1,
  },
  detailValue: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
    flex: 1,
  },
  idNumber: {
    color: '#fbbf24',
    fontFamily: 'Courier',
    fontWeight: '900',
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: 20,
    borderTopWidth: 2,
    borderTopColor: 'rgba(255,255,255,0.2)',
  },
  barcodeSection: {
    alignItems: 'center',
  },
  barcodeNumber: {
    color: '#fff',
    fontFamily: 'Courier',
    fontSize: 12,
    marginTop: 8,
    fontWeight: '900',
  },
  signatureSection: {
    alignItems: 'center',
  },
  signatureLabel: {
    color: '#cbd5e1',
    fontSize: 10,
    fontWeight: '700',
    letterSpacing: 1,
  },
  signatureLine: {
    width: 120,
    height: 2,
    backgroundColor: '#fff',
    marginVertical: 6,
  },
  principalName: {
    color: '#fff',
    fontSize: 12,
    fontWeight: '700',
  },
  actionButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  downloadButton: {
    flex: 1,
    backgroundColor: '#3b82f6',
    padding: 16,
    borderRadius: 12,
    marginRight: 8,
    alignItems: 'center',
  },
  shareButton: {
    flex: 1,
    backgroundColor: '#8b5cf6',
    padding: 16,
    borderRadius: 12,
    marginHorizontal: 8,
    alignItems: 'center',
  },
  refreshButton: {
    flex: 1,
    backgroundColor: '#10b981',
    padding: 16,
    borderRadius: 12,
    marginLeft: 8,
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '700',
  },
  cardInfo: {
    backgroundColor: '#fff',
    borderRadius: 16,
    padding: 20,
  },
  infoItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f1f5f9',
  },
  infoTitle: {
    color: '#64748b',
    fontSize: 14,
    fontWeight: '600',
  },
  infoValue: {
    color: '#1e293b',
    fontSize: 14,
    fontWeight: '700',
  },
  loadingContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  emptyContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
  },
  emptyTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#64748b',
    marginBottom: 12,
  },
  emptyText: {
    fontSize: 16,
    color: '#94a3b8',
    textAlign: 'center',
    lineHeight: 24,
  },
});

export default MobileAppIDCardScreen;