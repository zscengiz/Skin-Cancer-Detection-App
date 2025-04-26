import React, { useEffect, useState } from 'react';
import { View, Image, StyleSheet } from 'react-native';
import images from '../constants/images';

const HealthIconLoader = () => {
  const [index, setIndex] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setIndex((prev) => (prev + 1) % images.healthIcons.length);
    }, 800);

    return () => clearInterval(interval);
  }, []);

  return (
    <View style={styles.container}>
      <Image source={images.healthIcons[index]} style={styles.icon} />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: 'white',
    justifyContent: 'center',
    alignItems: 'center',
    elevation: 10,
    shadowColor: 'black',
    shadowOpacity: 0.1,
    shadowOffset: { width: 0, height: 4 },
  },
  icon: {
    width: 60,
    height: 60,
    resizeMode: 'contain',
  },
});

export default HealthIconLoader;
