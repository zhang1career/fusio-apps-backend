/**
 * fusio-sdk types are generated from stock TypeAPI; custom fusio-impl adds usability and responseHeaders.
 * `export {}` makes this a module so `declare module 'fusio-sdk'` merges (augments) the package.
 *
 * `responseHeaders` is a per-Operation map that, when set, force-overrides same-named headers on the outbound
 * response. Common use case: CORS / Cache-Control. BackendOperationCreate and BackendOperationUpdate both extend
 * BackendOperation in the SDK, so augmenting the base interface here propagates to all three.
 */
export {};

declare module 'fusio-sdk' {
  interface BackendOperation {
    usability?: number | null;
    responseHeaders?: Record<string, string> | null;
  }
}
