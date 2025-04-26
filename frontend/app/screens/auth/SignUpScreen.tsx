import React, { useState } from 'react';
import { View, Text, TextInput, StyleSheet, TouchableOpacity, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';
import colors from '../../../constants/colors';
import fonts from '../../../constants/fonts/fonts';
import { Ionicons } from '@expo/vector-icons';

const SignUpScreen = () => {
  const router = useRouter();

  const [name, setName] = useState('');
  const [surname, setSurname] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const [nameError, setNameError] = useState('');
  const [surnameError, setSurnameError] = useState('');
  const [emailError, setEmailError] = useState('');
  const [passwordError, setPasswordError] = useState('');

  const validateInputs = () => {
    let isValid = true;

    const nameSurnameRegex = /^[a-zA-ZğüşöçıİĞÜŞÖÇ\s]+$/;

    if (!name.trim() || name.length < 3) {
      setNameError('Name must be at least 3 characters.');
      isValid = false;
    } else if (!nameSurnameRegex.test(name)) {
      setNameError('Name must contain only letters.');
      isValid = false;
    } else {
      setNameError('');
    }

    if (!surname.trim() || surname.length < 3) {
      setSurnameError('Surname must be at least 3 characters.');
      isValid = false;
    } else if (!nameSurnameRegex.test(surname)) {
      setSurnameError('Surname must contain only letters.');
      isValid = false;
    } else {
      setSurnameError('');
    }

    const emailRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$/;

    if (!email.trim() || !emailRegex.test(email)) {
      setEmailError('Invalid email format.');
      isValid = false;
    } else {
      const allowedDomains = [
        'gmail.com', 'hotmail.com', 'outlook.com', 'icloud.com', 'yahoo.com',
        'edu.tr', 'edu.com', 'bilkent.edu.tr', 'hacettepe.edu.tr', 'ostimteknik.edu.tr'
      ];
      const domain = email.split('@').pop()?.toLowerCase();
      const isDomainAllowed = allowedDomains.some(d => domain === d || domain?.endsWith(d));
      if (!isDomainAllowed) {
        setEmailError('Email must be from an approved domain.');
        isValid = false;
      } else {
        setEmailError('');
      }
    }

    const lengthRegex = /.{8,}/;
    const upperCaseRegex = /[A-Z]/;
    const lowerCaseRegex = /[a-z]/;
    const numberRegex = /[0-9]/;
    const specialCharRegex = /[!@#$%^&*(),.?":{}|<>]/;

    if (!password.trim()) {
      setPasswordError('Password required.');
      isValid = false;
    } else if (!lengthRegex.test(password)) {
      setPasswordError('Password must be at least 8 characters.');
      isValid = false;
    } else if (!upperCaseRegex.test(password)) {
      setPasswordError('Must include one uppercase letter.');
      isValid = false;
    } else if (!lowerCaseRegex.test(password)) {
      setPasswordError('Must include one lowercase letter.');
      isValid = false;
    } else if (!numberRegex.test(password)) {
      setPasswordError('Must include one number.');
      isValid = false;
    } else if (!specialCharRegex.test(password)) {
      setPasswordError('Must include one special character.');
      isValid = false;
    } else {
      setPasswordError('');
    }

    return isValid;
  };

  const handleSignUp = async () => {
    if (!validateInputs()) {
      return;
    }

    setIsLoading(true);
    try {
      await new Promise(resolve => setTimeout(resolve, 2000));
      alert('Signup Successful!');
      router.push('/screens/WelcomeScreen');
    } catch (error) {
      console.error(error);
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={colors.primary} />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Create an Account</Text>

      <TextInput
        placeholder="Name"
        placeholderTextColor={colors.textSecondary}
        style={styles.input}
        value={name}
        onChangeText={setName}
      />
      {nameError ? <Text style={styles.errorText}>{nameError}</Text> : null}

      <TextInput
        placeholder="Surname"
        placeholderTextColor={colors.textSecondary}
        style={styles.input}
        value={surname}
        onChangeText={setSurname}
      />
      {surnameError ? <Text style={styles.errorText}>{surnameError}</Text> : null}

      <TextInput
        placeholder="Email"
        placeholderTextColor={colors.textSecondary}
        style={styles.input}
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
      />
      {emailError ? <Text style={styles.errorText}>{emailError}</Text> : null}

      <View style={styles.passwordContainer}>
        <TextInput
          placeholder="Password"
          placeholderTextColor={colors.textSecondary}
          style={styles.passwordInput}
          value={password}
          onChangeText={setPassword}
          secureTextEntry={!showPassword}
        />
        <TouchableOpacity onPress={() => setShowPassword(!showPassword)}>
          <Ionicons
            name={showPassword ? 'eye-off' : 'eye'}
            size={24}
            color={colors.textSecondary}
          />
        </TouchableOpacity>
      </View>
      {passwordError ? <Text style={styles.errorText}>{passwordError}</Text> : null}

      <TouchableOpacity style={styles.button} onPress={handleSignUp}>
        <Text style={styles.buttonText}>Sign Up</Text>
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
  passwordContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#E0F2FE',
    borderRadius: 8,
    paddingHorizontal: 16,
    marginBottom: 8,
  },
  passwordInput: {
    flex: 1,
    paddingVertical: 12,
    fontSize: 16,
    fontFamily: fonts.regular,
    color: colors.textPrimary,
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

export default SignUpScreen;
