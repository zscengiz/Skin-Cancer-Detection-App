import React from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity } from 'react-native';
import colors from '../../constants/Colors';
import images from '../../constants/images';
import fonts from '../../constants/fonts/fonts';

import { useRouter } from 'expo-router';

const WelcomeScreen = () => {
  const router = useRouter();

  return (
    <View style={styles.container}>
      <Image source={images.doctor} style={styles.image} />
      <Text style={styles.title}>Let's get started</Text>
      <Text style={styles.subtitle}>We are happy to see you again</Text>

      <TouchableOpacity style={styles.emailButton} onPress={() => router.push('/screens/auth/LoginScreen')}>
        <Text style={styles.emailButtonText}>Sign in with Email</Text>
      </TouchableOpacity>

      <TouchableOpacity style={styles.googleButton}>
        <Text style={styles.googleButtonText}>Continue with Google</Text>
      </TouchableOpacity>

      <View style={styles.footer}>
        <Text style={styles.footerText}>Don't have an account?</Text>
        <TouchableOpacity onPress={() => router.push('/screens/auth/SignUpScreen')}>
          <Text style={styles.footerLink}> Sign up</Text>
        </TouchableOpacity>
      </View>

      <Text style={styles.termsText}>
        By signing up or logging in, I accept the app's
        <Text style={styles.link}> Terms of service </Text> and
        <Text style={styles.link}> Privacy policy</Text>.
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    alignItems: 'center',
    paddingHorizontal: 24,
    paddingTop: 60,
  },
  image: {
    width: 220,
    height: 220,
    resizeMode: 'contain',
    marginBottom: 24,
  },
  title: {
    fontSize: 24,
    fontFamily: fonts.bold,
    color: colors.textPrimary,
  },
  subtitle: {
    fontSize: 16,
    fontFamily: fonts.regular,
    color: colors.textSecondary,
    marginVertical: 12,
  },
  emailButton: {
    width: '100%',
    paddingVertical: 14,
    backgroundColor: colors.primary,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 20,
  },
  emailButtonText: {
    color: colors.secondary,
    fontSize: 16,
    fontFamily: fonts.bold,
  },
  googleButton: {
    width: '100%',
    paddingVertical: 14,
    backgroundColor: colors.secondary,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 12,
    borderWidth: 1,
    borderColor: colors.primary,
  },
  googleButtonText: {
    color: colors.primary,
    fontSize: 16,
    fontFamily: fonts.bold,
  },
  footer: {
    flexDirection: 'row',
    marginTop: 24,
  },
  footerText: {
    color: colors.textSecondary,
    fontFamily: fonts.regular,
  },
  footerLink: {
    color: colors.primary,
    fontWeight: 'bold',
    fontFamily: fonts.bold,
  },
  termsText: {
    textAlign: 'center',
    fontSize: 12,
    color: colors.textSecondary,
    marginTop: 32,
    paddingHorizontal: 12,
    fontFamily: fonts.regular,
  },
  link: {
    color: colors.primary,
    fontFamily: fonts.bold,
  },
});

export default WelcomeScreen;
