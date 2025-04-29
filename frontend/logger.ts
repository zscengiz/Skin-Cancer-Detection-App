const Logger = {
  log: (...args: any[]) => {
    if (__DEV__) console.log(...args);
  },

  info: (...args: any[]) => {
    if (__DEV__) console.info(...args);
  },

  warn: (...args: any[]) => {
    if (__DEV__) console.warn(...args);
  },

  error: (...args: any[]) => {
    if (__DEV__) console.error(...args);
  },
};

export default Logger;
