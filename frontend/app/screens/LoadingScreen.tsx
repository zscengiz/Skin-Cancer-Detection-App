import React from 'react';
import { View, StyleSheet } from 'react-native';
import HealthIconLoader from '../../components/HealthIconLoader';
import colors from '../../constants/Colors';

const LoadingScreen = () => {
  return (
    <View style={styles.container}>
      <HealthIconLoader />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export default LoadingScreen;
