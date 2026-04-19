/// <reference types="@angular/localize" />

(() => {
  try {
    const saved = localStorage.getItem('fusio-theme');
    document.documentElement.setAttribute(
      'data-bs-theme',
      saved === 'dark' ? 'dark' : 'light',
    );
  } catch {
    document.documentElement.setAttribute('data-bs-theme', 'light');
  }
})();

import { enableProdMode } from '@angular/core';
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';

import { AppModule } from './app/app.module';
import { environment } from './environments/environment';

if (environment.production) {
  enableProdMode();
}

platformBrowserDynamic().bootstrapModule(AppModule)
  .catch(err => console.error(err));
