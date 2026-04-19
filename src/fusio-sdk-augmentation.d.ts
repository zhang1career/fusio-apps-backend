/**
 * fusio-sdk types are generated from stock TypeAPI; custom fusio-impl adds usability.
 * `export {}` makes this a module so `declare module 'fusio-sdk'` merges (augments) the package.
 */
export {};

declare module 'fusio-sdk' {
  interface BackendOperation {
    usability?: number | null;
  }
}
