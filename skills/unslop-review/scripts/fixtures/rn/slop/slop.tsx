// Fixture: every line below is deliberate slop for slop-grep.sh (rn) to find.
import React from 'react';
import { View, Text, TouchableOpacity, ActivityIndicator, Modal, Dimensions, StyleSheet, ScrollView } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { BlurView } from 'expo-blur';
import { MaterialIcons } from '@expo/vector-icons';
import Animated, { Easing, withRepeat, withTiming, withSpring, FadeInDown } from 'react-native-reanimated';

export function SlopScreen({ items }: { items: string[] }) {
  async function load() {
    try {
      return [1];
    } catch (e) {
      return [];
    }
  }
  return (
    <View style={styles.page}>
      <LinearGradient colors={['#8b5cf6', '#ec4899']} style={styles.hero}>
        <Text style={styles.title}>Welcome back, Sam! 👋</Text>
        <Text style={{ fontStyle: 'italic', letterSpacing: -0.5, textTransform: 'uppercase', fontWeight: '800' }}>Supercharge your workflow</Text>
        <Text allowFontScaling={false} style={{ fontFamily: 'Menlo', color: '#ffffff' }}>Tap here to continue</Text>
      </LinearGradient>
      <TouchableOpacity android_ripple={{ color: '#fff' }}><MaterialIcons name="menu" /></TouchableOpacity>
      <ActivityIndicator />
      <BlurView intensity={40} />
      <Modal visible onRequestClose={() => {}} />
      <ScrollView bounces={false} overScrollMode="never" />
      {items.map((x, i) => (
        <Animated.View key={x} entering={FadeInDown.delay(i * 80).duration(600)} style={styles.row} />
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  page: { paddingTop: 44, padding: 13, gap: 7 },
  hero: { shadowColor: '#8b5cf6', shadowRadius: 30, borderBottomWidth: 1, elevation: 8 },
  title: { color: 'white' },
  row: { marginTop: 20 },
});

export function motion() {
  const a = Easing.bounce;
  const b = withRepeat(withTiming(1, { duration: 1200 }), -1);
  const c = withSpring(0);
  const w = Dimensions.get('window').width;
  const s = { scale: 0 };
  ScreenOrientation.lockAsync(1);
  return [a, b, c, w, s];
}
export const nav = { gestureEnabled: false, headerTitle: 'Done!' };
