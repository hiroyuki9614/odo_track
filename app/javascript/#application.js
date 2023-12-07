// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import '@hotwired/turbo-rails';
import 'controllers';
import 'custom/menu';
import 'custom/form';
import 'bootstrap';
import 'popper';
import jquery from 'jquery';
window.$ = jquery;
window.jQuery = jquery;
import * as bootstrap from 'bootstrap';
