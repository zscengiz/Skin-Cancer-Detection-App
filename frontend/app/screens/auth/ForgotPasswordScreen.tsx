import React, { useState } from 'react';
import { View, Text, TextInput, StyleSheet, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import colors from '../../../constants/colors';
import fonts from '../../../constants/fonts/fonts';
import apiService from '../../../services/ApiService';
import Toast from 'react-native-toast-message';
import LoadingScreen from '../LoadingScreen';

const ForgotPasswordScreen = () => {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [emailError, setEmailError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const validateEmail = (inputEmail: string) => {
    const emailRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$/;
    return emailRegex.test(inputEmail.trim());
  };

  const handleForgotPassword = async () => {
    setEmailError('');
    if (!email.trim()) {
      setEmailError('Please enter your email.');
      return;
    }
    if (!validateEmail(email)) {
      setEmailError('Invalid email format.');
      return;
    }

    setIsLoading(true);
    try {
      await apiService.forgotPassword({ email });

      Toast.show({
        type: 'success',
        text1: 'Success',
        text2: 'Password reset link sent to your email.',
        position: 'top',
        visibilityTime: 3000,
      });

      setTimeout(() => {
        router.replace('/screens/WelcomeScreen');
      }, 1000);
    } catch (error: any) {
      const errorMessage =
        typeof error === 'string' ? error :
          error?.message ||
          error?.response?.data?.error?.message || 'Failed to send reset link.';
      Toast.show({
        type: 'error',
        text1: 'Signup Error',
        text2: errorMessage,
        position: 'top',
        visibilityTime: 3000,
      });

    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return <LoadingScreen />;
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Forgot Password</Text>
      <TextInput
        placeholder="Enter your email"
        placeholderTextColor={colors.textSecondary}
        style={styles.input}
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        autoCapitalize="none"
      />
      {emailError ? <Text style={styles.errorText}>{emailError}</Text> : null}

      <TouchableOpacity style={styles.button} onPress={handleForgotPassword}>
        <Text style={styles.buttonText}>Send Reset Link</Text>
      </TouchableOpacity>
    </View>
  );
};


const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    padding: 24,
    justifyContent: 'center',
  },
  title: {
    fontSize: 28,
    fontFamily: fonts.bold,
    color: colors.primary,
    marginBottom: 24,
    textAlign: 'center',
  },
  input: {
    backgroundColor: '#E0F2FE',
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 8,
    fontSize: 16,
    fontFamily: fonts.regular,
    marginBottom: 8,
    color: colors.textPrimary,
  },
  errorText: {
    color: 'red',
    fontSize: 12,
    marginBottom: 8,
    fontFamily: fonts.regular,
    marginLeft: 4,
  },
  button: {
    backgroundColor: colors.primary,
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 12,
  },
  buttonText: {
    color: colors.secondary,
    fontSize: 16,
    fontFamily: fonts.bold,
  },
  loadingContainer: {
    flex: 1,
    backgroundColor: colors.background,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export default ForgotPasswordScreen;
