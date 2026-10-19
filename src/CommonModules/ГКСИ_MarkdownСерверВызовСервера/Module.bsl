#Область ПрограммныйИнтерфейс

// Возвращает текст библиотеки разметки showdown.
//
// Возвращаемое значение:
//  Строка - текст макета ГКСИ_showdown.
Функция ПолучитьТекстКомпонентыShowodwn() Экспорт
	БиблиотекаТекст=ПолучитьОбщийМакет("ГКСИ_showdown").ПолучитьТекст();

	Возврат БиблиотекаТекст;
КонецФункции

// Возвращает текст библиотеки подсветки синтаксиса highlight.js.
//
// Возвращаемое значение:
//  Строка - текст макета ГКСИ_highligthjs.
Функция ПолучитьТекстКомпонентыHighligthjs() Экспорт
	БиблиотекаТекст=ПолучитьОбщийМакет("ГКСИ_highligthjs").ПолучитьТекст();
	Возврат БиблиотекаТекст;
КонецФункции

// Формирует HTML-документ для предпросмотра текста Markdown.
//
// Параметры:
//  ВариантПодсветкиСинтаксиса - Строка - имя варианта подсветки синтаксиса.
//  ШиринаКартинок - Строка - CSS-ширина картинок.
//  КодЯзыка - Строка - код языка для обогащения терминами глоссария.
//  СсылкиJSON - Строка - JSON-массив карты вики-ссылок на группы и шаги
//               (см. ГКСИ_СсылкиСценариев.СсылкиJSONДляКлиента). Пустая
//               строка или "[]" - вики-ссылки в предпросмотре не разбираются.
//
// Возвращаемое значение:
//  Строка - HTML-документ.
Функция СформироватьТекстHTMLДляТекстаMarkdown(ВариантПодсветкиСинтаксиса, ШиринаКартинок = "", КодЯзыка = "", СсылкиJSON = "[]") Экспорт
	БиблиотекаТекст=ПолучитьТекстКомпонентыShowodwn();
	ТекстРазукрашивателя=ПолучитьТекстКомпонентыHighligthjs();
	СтильПодсветкиСинтаксиса=ТекстСтиляПодсветкиСинтаксиса(ВариантПодсветкиСинтаксиса);
	СтильКартинок = ГКСИ_MarkdownПереопределяемый.СтильИзображений(ШиринаКартинок);
	ТерминыJSON = ГКСИ_Глоссарий.ТерминыДляПревьюJSON(КодЯзыка);
	ТекстБитойСсылки = НСтр("ru = 'Ссылка не найдена: %1'");
	Если ПустаяСтрока(СсылкиJSON) Тогда
		СсылкиJSON = "[]";
	КонецЕсли;
	СтрокиJS = Новый Массив;
	СтрокиJS.Добавить("function escapeRegExp(s){return s.replace(/[.*+?^${}()|[\]\\]/g, '\\\\$&');}");
	СтрокиJS.Добавить("function enrichTerms(){");
	СтрокиJS.Добавить("  var T=window.__gksiTerms; if (!T || T.length===0) return;");
	СтрокиJS.Добавить("  var root=document.getElementById('wiki-container'); if (!root) return;");
	СтрокиJS.Добавить("  var walker=document.createTreeWalker(root, NodeFilter.SHOW_TEXT, {");
	СтрокиJS.Добавить("    acceptNode: function(node){");
	СтрокиJS.Добавить("      if (!node.nodeValue || !node.nodeValue.trim()) return NodeFilter.FILTER_REJECT;");
	СтрокиJS.Добавить("      var p=node.parentNode;");
	СтрокиJS.Добавить("      while (p && p!==root){");
	СтрокиJS.Добавить("        var tag=(p.tagName||'').toUpperCase();");
	СтрокиJS.Добавить("        if (tag==='A'||tag==='CODE'||tag==='PRE'||tag==='SCRIPT'||tag==='STYLE') return NodeFilter.FILTER_REJECT;");
	СтрокиJS.Добавить("        if (p.classList && p.classList.contains('gksi-term')) return NodeFilter.FILTER_REJECT;");
	СтрокиJS.Добавить("        p=p.parentNode;");
	СтрокиJS.Добавить("      }");
	СтрокиJS.Добавить("      return NodeFilter.FILTER_ACCEPT;");
	СтрокиJS.Добавить("    }");
	СтрокиJS.Добавить("  });");
	СтрокиJS.Добавить("  var nodes=[]; var n; while (n=walker.nextNode()) nodes.push(n);");
	СтрокиJS.Добавить("  for (var i=0;i<nodes.length;i++){");
	СтрокиJS.Добавить("    var tn=nodes[i]; var text=tn.nodeValue;");
	СтрокиJS.Добавить("    var best=null, bestIdx=-1, bestLen=0;");
	СтрокиJS.Добавить("    for (var k=0;k<T.length;k++){");
	СтрокиJS.Добавить("      var name=T[k].name; if (!name) continue;");
	СтрокиJS.Добавить("      var re=new RegExp('(^|[^\\\\p{L}\\\\p{N}_])('+escapeRegExp(name)+')(?=[^\\\\p{L}\\\\p{N}_]|$)','iu');");
	СтрокиJS.Добавить("      var m=text.match(re); if (!m) continue;");
	СтрокиJS.Добавить("      var idx=text.indexOf(m[2]);");
	СтрокиJS.Добавить("      if (best===null || idx<bestIdx || (idx===bestIdx && name.length>bestLen)){");
	СтрокиJS.Добавить("        best=T[k]; bestIdx=idx; bestLen=name.length;");
	СтрокиJS.Добавить("      }");
	СтрокиJS.Добавить("    }");
	СтрокиJS.Добавить("    if (!best) continue;");
	СтрокиJS.Добавить("    var name=best.name;");
	СтрокиJS.Добавить("    var before=text.substring(0,bestIdx);");
	СтрокиJS.Добавить("    var matched=text.substring(bestIdx,bestIdx+name.length);");
	СтрокиJS.Добавить("    var after=text.substring(bestIdx+name.length);");
	СтрокиJS.Добавить("    var span=document.createElement('span');");
	СтрокиJS.Добавить("    span.className='gksi-term';");
	СтрокиJS.Добавить("    span.setAttribute('data-term-guid', best.guid||'');");
	СтрокиJS.Добавить("    span.setAttribute('title', best.title||'');");
	СтрокиJS.Добавить("    span.appendChild(document.createTextNode(matched));");
	СтрокиJS.Добавить("    var parent=tn.parentNode;");
	СтрокиJS.Добавить("    if (before) parent.insertBefore(document.createTextNode(before), tn);");
	СтрокиJS.Добавить("    parent.insertBefore(span, tn);");
	СтрокиJS.Добавить("    if (after) parent.insertBefore(document.createTextNode(after), tn);");
	СтрокиJS.Добавить("    parent.removeChild(tn);");
	СтрокиJS.Добавить("  }");
	СтрокиJS.Добавить("}");
	// GitHub Alerts: > \x5B!NOTE] / [!TIP] / \[!IMPORTANT] / \[!WARNING] / \[!CAUTION]
	СтрокиJS.Добавить("var gksiAlertIcons = {");
	СтрокиJS.Добавить("  NOTE:      '<svg class=""octicon"" viewBox=""0 0 16 16"" width=""16"" height=""16"" aria-hidden=""true""><path d=""M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8Zm8-6.5a6.5 6.5 0 1 0 0 13 6.5 6.5 0 0 0 0-13ZM6.5 7.75A.75.75 0 0 1 7.25 7h1a.75.75 0 0 1 .75.75v2.75h.25a.75.75 0 0 1 0 1.5h-2a.75.75 0 0 1 0-1.5h.25v-2h-.25a.75.75 0 0 1-.75-.75ZM8 6a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z""></path></svg>',");
	СтрокиJS.Добавить("  TIP:       '<svg class=""octicon"" viewBox=""0 0 16 16"" width=""16"" height=""16"" aria-hidden=""true""><path d=""M8 1.5c-2.363 0-4.467.86-6.118 2.302-.823.717-1.5 1.594-1.887 2.65H2.5a.5.5 0 0 0-.5.5v.776c0 .967.371 1.857 1.015 2.527A4.04 4.04 0 0 0 1.5 13h13a4.04 4.04 0 0 0-1.515-2.745A4.6 4.6 0 0 0 14 9.828V9.05a.5.5 0 0 0-.5-.5h-.495c-.387-1.056-1.064-1.933-1.887-2.65C12.467 2.36 10.363 1.5 8 1.5Zm0-1c3.59 0 6.637 2.46 7.59 5.795.04.144.06.29.06.435 0 .69-.36 1.31-.92 1.66l-.18.12V12a1 1 0 0 1-1 1H2.45a1 1 0 0 1-1-1v-.49l-.18-.12A1.99 1.99 0 0 1 .35 8.73c0-.146.02-.29.06-.435C1.363 3.46 4.41 1.5 8 1.5Z""></path></svg>',");
	СтрокиJS.Добавить("  IMPORTANT: '<svg class=""octicon"" viewBox=""0 0 16 16"" width=""16"" height=""16"" aria-hidden=""true""><path d=""M0 1.75C0 .784.784 0 1.75 0h12.5C15.216 0 16 .784 16 1.75v9.5A1.75 1.75 0 0 1 14.25 13H8.06l-2.573 2.573A1.458 1.458 0 0 1 3 14.543V13H1.75A1.75 1.75 0 0 1 0 11.25Zm1.75-.25a.25.25 0 0 0-.25.25v9.5c0 .138.112.25.25.25h2a.75.75 0 0 1 .75.75v2.19l2.72-2.72a.749.749 0 0 1 .53-.22h6.5a.25.25 0 0 0 .25-.25v-9.5a.25.25 0 0 0-.25-.25Zm7 2.25v2c0 .138-.112.25-.25.25h-3a.25.25 0 0 1-.25-.25v-2c0-.138.112-.25.25-.25h3c.138 0 .25.112.25.25Zm.5 4.5a.5.5 0 0 1-.5.5h-4a.5.5 0 0 1 0-1h4a.5.5 0 0 1 .5.5Z""></path></svg>',");
	СтрокиJS.Добавить("  WARNING:   '<svg class=""octicon"" viewBox=""0 0 16 16"" width=""16"" height=""16"" aria-hidden=""true""><path d=""M6.457 1.047c.659-1.234 2.427-1.234 3.086 0l6.082 11.378A1.75 1.75 0 0 1 14.082 15H1.918a1.75 1.75 0 0 1-1.543-2.575Zm1.763.707a.25.25 0 0 0-.44 0L1.698 13.132a.25.25 0 0 0 .22.368h12.164a.25.25 0 0 0 .22-.368Zm.53 3.996v2.5a.75.75 0 0 1-1.5 0v-2.5a.75.75 0 0 1 1.5 0ZM9 11a1 1 0 1 1-2 0 1 1 0 0 1 2 0Z""></path></svg>',");
	СтрокиJS.Добавить("  CAUTION:   '<svg class=""octicon"" viewBox=""0 0 16 16"" width=""16"" height=""16"" aria-hidden=""true""><path d=""M4.47.22A.749.749 0 0 1 5 0h6c.199 0 .389.079.53.22l4.25 4.25c.141.14.22.331.22.53v6a.749.749 0 0 1-.22.53l-4.25 4.25A.749.749 0 0 1 11 16H5a.749.749 0 0 1-.53-.22L.22 11.53A.749.749 0 0 1 0 11V5c0-.199.079-.389.22-.53Zm.84 1.28L1.5 5.31v5.38l3.81 3.81h5.38l3.81-3.81V5.31L10.69 1.5ZM8 4a.75.75 0 0 1 .75.75v3.5a.75.75 0 0 1-1.5 0v-3.5A.75.75 0 0 1 8 4Zm0 8a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z""></path></svg>'");
	СтрокиJS.Добавить("};");
	// Палитра цветов GitHub-default для inline-стилей (работает в любом контексте без внешнего CSS).
	СтрокиJS.Добавить("var gksiAlertPalette = {");
	СтрокиJS.Добавить("  NOTE:      { b: '#0969da', bg: '#ddf4ff', c: '#052e6b' },");
	СтрокиJS.Добавить("  TIP:       { b: '#1a7f37', bg: '#dafbe1', c: '#0d5223' },");
	СтрокиJS.Добавить("  IMPORTANT: { b: '#8250df', bg: '#f2e8ff', c: '#3d1d8a' },");
	СтрокиJS.Добавить("  WARNING:   { b: '#9a6700', bg: '#fff8c5', c: '#6b4f00' },");
	СтрокиJS.Добавить("  CAUTION:   { b: '#cf222e', bg: '#ffebe9', c: '#7a121b' }");
	СтрокиJS.Добавить("};");
	СтрокиJS.Добавить("function gksiRenderAlert(type, titleOverride, body){");
	СтрокиJS.Добавить("  var P = gksiAlertPalette[type] || gksiAlertPalette.NOTE;");
	СтрокиJS.Добавить("  var bs = 'padding:8px 16px;margin:4px 0 16px;'");
	СтрокиJS.Добавить("    + 'border-left:4px solid ' + P.b + ';'");
	СтрокиJS.Добавить("    + 'background-color:' + P.bg + ';'");
	СтрокиJS.Добавить("    + 'color:' + P.c + ';'");
	СтрокиJS.Добавить("    + 'border-radius:4px;';");
	СтрокиJS.Добавить("  var ts = 'display:flex;align-items:center;gap:6px;'");
	СтрокиJS.Добавить("    + 'font-weight:600;margin:0 0 4px;'");
	СтрокиJS.Добавить("    + 'font-size:0.85em;color:' + P.c + ';';");
	СтрокиJS.Добавить("  var titleText = (titleOverride || type).trim();");
	СтрокиJS.Добавить("  var inner = body.split('\\n')");
	СтрокиJS.Добавить("    .map(function(l){ return l.replace(/^[ ]{0,3}>[ ]?/, ''); })");
	СтрокиJS.Добавить("    .join('\\n').replace(/\\s+$/, '');");
	СтрокиJS.Добавить("  var icon = gksiAlertIcons[type] || '';");
	СтрокиJS.Добавить("  var NL = String.fromCharCode(10);");
	СтрокиJS.Добавить("  var Q = String.fromCharCode(34);");
	СтрокиJS.Добавить("  var divOpen = '<div class=' + Q");
	СтрокиJS.Добавить("    + 'markdown-alert markdown-alert-' + type.toLowerCase() + Q");
	СтрокиJS.Добавить("    + ' style=' + Q + bs + Q + '>';");
	СтрокиJS.Добавить("  var titleOpen = '<p class=' + Q + 'markdown-alert-title' + Q");
	СтрокиJS.Добавить("    + ' style=' + Q + ts + Q + '>'");
	СтрокиJS.Добавить("    + icon + ' ' + titleText + '</p>' + NL;");
	СтрокиJS.Добавить("  return divOpen + NL + titleOpen + inner + NL + '</div>' + NL;");
	СтрокиJS.Добавить("}");
	СтрокиJS.Добавить("function gksiPreprocessAlerts(text){");
	СтрокиJS.Добавить("  try {");
	СтрокиJS.Добавить("    var re = /^[ ]{0,3}>?[ ]{0,3}[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)(?:\\|([^\\]\\n]*))?\\][ ]*\\r?\\n((?:(?![ ]{0,3}>?[ ]{0,3}[!|\\r?\\n\\r?\\n).+\\r?\\n?)*)/gm;");
	СтрокиJS.Добавить("    return text.replace(re, function(_, head, type, titleOverride, body){");
	СтрокиJS.Добавить("      return gksiRenderAlert(type, titleOverride, body);");
	СтрокиJS.Добавить("    });");
	СтрокиJS.Добавить("  } catch(_e){ try { console.log('[GKSI][alerts] preprocess error:', _e.message); } catch(_){} return text; }");
	СтрокиJS.Добавить("}");
	// Вики-ссылки [[Имя]] / [[Имя|Текст]] на группы и шаги демонстрационных
	// сценариев. Карта ссылок приходит из ГКСИ_СсылкиСценариев и кладётся в
	// window.__gksiLinks. Разбор синтаксиса полностью повторяет серверную
	// функцию ГКСИ_СсылкиСценариев.ПодставитьСсылкиВТекст, включая пропуск
	// картинок ![[...]] и разметку ссылки (порядок атрибутов class, href,
	// data-gksi-anchor важен: на него опирается альбом процессов).
	СтрокиJS.Добавить("var gksiLinkBrokenTemplate = '" + ТекстБитойСсылки + "';");
	СтрокиJS.Добавить("function gksiEsc(s){ return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/""/g,'&quot;'); }");
	СтрокиJS.Добавить("function gksiPreprocessLinks(text){");
	СтрокиJS.Добавить("  try {");
	СтрокиJS.Добавить("    var L = window.__gksiLinks;");
	СтрокиJS.Добавить("    if (!L || L.length === 0) return text;");
	СтрокиJS.Добавить("    var byName = Object.create(null);");
	СтрокиJS.Добавить("    var byCode = Object.create(null);");
	СтрокиJS.Добавить("    for (var i = 0; i < L.length; i++){");
	СтрокиJS.Добавить("      var e = L[i];");
	СтрокиJS.Добавить("      var codes = (e.codes && e.codes.length) ? e.codes : (e.code ? [e.code] : []);");
	СтрокиJS.Добавить("      for (var j = 0; j < codes.length; j++){");
	СтрокиJS.Добавить("        if (byCode[codes[j]] === undefined) byCode[codes[j]] = e;");
	СтрокиJS.Добавить("      }");
	СтрокиJS.Добавить("      if (e.name){");
	СтрокиJS.Добавить("        var key = e.name.toUpperCase();");
	СтрокиJS.Добавить("        if (byName[key] === undefined) byName[key] = e;");
	СтрокиJS.Добавить("        else if (byName[key] !== e) byName[key] = false;");
	СтрокиJS.Добавить("      }");
	СтрокиJS.Добавить("    }");
	СтрокиJS.Добавить("    var out = '';");
	СтрокиJS.Добавить("    var pos = 0;");
	СтрокиJS.Добавить("    var len = text.length;");
	СтрокиJS.Добавить("    while (pos < len){");
	СтрокиJS.Добавить("      var open = text.indexOf('[[', pos);");
	СтрокиJS.Добавить("      if (open < 0){ out += text.substring(pos); break; }");
	СтрокиJS.Добавить("      if (open > 0 && text.charAt(open - 1) === '!'){ out += text.substring(pos, open + 1); pos = open + 2; continue; }");
	СтрокиJS.Добавить("      var close = text.indexOf(']]', open + 2);");
	СтрокиJS.Добавить("      if (close < 0){ out += text.substring(pos); break; }");
	СтрокиJS.Добавить("      var inner = text.substring(open + 2, close);");
	СтрокиJS.Добавить("      if (inner.indexOf('[') >= 0 || inner.indexOf(String.fromCharCode(10)) >= 0 || inner.indexOf(String.fromCharCode(13)) >= 0){");
	СтрокиJS.Добавить("        out += text.substring(pos, close + 2); pos = close + 2; continue;");
	СтрокиJS.Добавить("      }");
	СтрокиJS.Добавить("      var parts = inner.split('|');");
	СтрокиJS.Добавить("      var target = parts[0].replace(/^\s+|\s+$/g, '');");
	СтрокиJS.Добавить("      var label = parts.length > 1 ? parts[1].replace(/^\s+|\s+$/g, '') : target;");
	СтрокиJS.Добавить("      if (label === '') label = target;");
	СтрокиJS.Добавить("      out += text.substring(pos, open);");
	СтрокиJS.Добавить("      var found = byCode[target];");
	СтрокиJS.Добавить("      if (!found) found = byName[target.toUpperCase()];");
	СтрокиJS.Добавить("      if (!found && label !== target) found = byName[label.toUpperCase()];");
	СтрокиJS.Добавить("      if (!found){");
	СтрокиJS.Добавить("        out += '<span class=""gksi-link-broken"" title=""' + gksiEsc(gksiLinkBrokenTemplate.replace('%1', target)) + '"">' + gksiEsc(label) + '</span>';");
	СтрокиJS.Добавить("      } else {");
	СтрокиJS.Добавить("        var href = found.href ? found.href : ('#' + found.anchor);");
	СтрокиJS.Добавить("        out += '<a class=""gksi-link"" href=""' + gksiEsc(href) + '"" data-gksi-anchor=""' + found.anchor + '"">' + gksiEsc(label) + '</a>';");
	СтрокиJS.Добавить("      }");
	СтрокиJS.Добавить("      pos = close + 2;");
	СтрокиJS.Добавить("    }");
	СтрокиJS.Добавить("    return out;");
	СтрокиJS.Добавить("  } catch(_e){ try { console.log('[GKSI][links] preprocess error:', _e.message); } catch(_){} return text; }");
	СтрокиJS.Добавить("}");
	// ВРЕМЕННАЯ ДИАГНОСТИКА кликабельных ссылок в предпросмотре: внизу просмотра
	// выводится строка с состоянием карты ссылок и результатом предобработки.
	// Удалить после подтверждения, что ссылки работают.
	СтрокиJS.Добавить("function gksiDebugFooter(html, text){");
	СтрокиJS.Добавить("  try {");
	СтрокиJS.Добавить("    var L = window.__gksiLinks;");
	СтрокиJS.Добавить("    var opens = String(text).split('[[').length - 1;");
	СтрокиJS.Добавить("    var links = String(html).split('gksi-link').length - 1;");
	СтрокиJS.Добавить("    var div = document.createElement('div');");
	СтрокиJS.Добавить("    div.style.cssText = 'font:11px monospace;color:#b73535;border-top:1px dotted #b73535;margin-top:8px;padding-top:4px';");
	СтрокиJS.Добавить("    div.textContent = '[GKSI-DEBUG] карта=' + (L ? L.length : 'НЕТ')");
	СтрокиJS.Добавить("      + '; [[ в тексте=' + opens");
	СтрокиJS.Добавить("      + '; gksi-link в HTML=' + links");
	СтрокиJS.Добавить("      + '; fn=' + (typeof gksiPreprocessLinks);");
	СтрокиJS.Добавить("    return div;");
	СтрокиJS.Добавить("  } catch(_e){ return null; }");
	СтрокиJS.Добавить("}");
	JSОбогащение = СтрСоединить(СтрокиJS, Символы.ПС);
	СтильCSS=
"
|.gksi-term {
|    cursor: help;
|    border-bottom: 1px dotted #4a90e2;
|    color: inherit;
|}
|.gksi-term:hover {
|    background-color: #fffbe6;
|}
|/***** Ссылки на группы и шаги сценария [[Имя]] *****/
|.gksi-link {
|    color: #2f6fb5;
|    text-decoration: none;
|    border-bottom: 1px solid rgba(47, 111, 181, 0.4);
|    cursor: pointer;
|}
|.gksi-link:hover {
|    background-color: #eef5fd;
|    border-bottom-color: #2f6fb5;
|}
|.gksi-link-broken {
|    color: #b73535;
|    border-bottom: 1px dashed #b73535;
|    cursor: help;
|}
|h2, .wiki h1 {font-size: 20px;}
	|h3, .wiki h2 {font-size: 16px;}
	|h4, .wiki h3 {font-size: 13px;}
	|
	|
	|/***** Wiki *****/
	|div.wiki table {
	|  border-collapse: collapse;
	|  margin-bottom: 1em;
	|}
	|
	|div.wiki table, div.wiki td, div.wiki th {
	|  border: 1px solid #bbb;
	|  padding: 4px;
	|}
	|
	|div.wiki th{
	|	background-color: #EEEEEE;
	|}
	|
	|div.wiki .wiki-class-noborder, div.wiki .wiki-class-noborder td, div.wiki .wiki-class-noborder th {border:0;}
	|
	|div.wiki .external {
	|  background-position: 0% 60%;
	|  background-repeat: no-repeat;
	|  padding-left: 12px;
	|}
	|
	|div.wiki a {word-wrap: break-word;}
	|div.wiki a.new {color: #b73535;}
	|
	|div.wiki ul, div.wiki ol {margin-bottom:1em;}
	|div.wiki li>ul, div.wiki li>ol {margin-bottom: 0;}
	|
	|div.wiki pre {
	|  margin: 1em 1em 1em 1.6em;
	|  padding: 8px;
//	|  background-color: #fafafa;
	|  border: 1px solid #e2e2e2;
	|  border-radius: 3px;
	|  width:auto;
	|  overflow-x: auto;
	|  overflow-y: hidden;
	|}
	|
	|div.wiki ul.toc {
	|  background-color: #ffffdd;
	|  border: 1px solid #e4e4e4;
	|  padding: 4px;
	|  line-height: 1.2em;
	|  margin-bottom: 12px;
	|  margin-right: 12px;
	|  margin-left: 0;
	|  display: table
	|}
	|* html div.wiki ul.toc { width: 50%; } /* IE6 doesn't autosize div */
	|
	|div.wiki ul.toc.right { float: right; margin-left: 12px; margin-right: 0; width: auto; }
	|div.wiki ul.toc.left  { float: left; margin-right: 12px; margin-left: 0; width: auto; }
	|div.wiki ul.toc ul { margin: 0; padding: 0; }
	|div.wiki ul.toc li {list-style-type:none; margin: 0; font-size:12px;}
	|div.wiki ul.toc>li:first-child {margin-bottom: .5em; color: #777;}
	|div.wiki ul.toc li li {margin-left: 1.5em; font-size:10px;}
	|div.wiki ul.toc a {
	|  font-size: 0.9em;
	|  font-weight: normal;
	|  text-decoration: none;
	|  color: #606060;
	|}
	|div.wiki ul.toc a:hover { color: #c61a1a; text-decoration: underline;}
	|
	|a.wiki-anchor { display: none; margin-left: 6px; text-decoration: none; }
	|a.wiki-anchor:hover { color: #aaa !important; text-decoration: none; }
	|h1:hover a.wiki-anchor, h2:hover a.wiki-anchor, h3:hover a.wiki-anchor { display: inline; color: #ddd; }
	|
|div.wiki img {vertical-align:middle;}
|blockquote { font-style: italic; border-left: 3px solid #e0e0e0; padding-left: 0.6em; margin-left: 0;}
|blockquote blockquote { margin-left: 0;}

|/***** GitHub Alerts *****/
|.markdown-alert { padding: 8px 16px; margin: 4px 0 16px; border-left: 4px solid; border-radius: 4px; }
|.markdown-alert .markdown-alert-title { display: flex; align-items: center; gap: 6px; font-weight: 600; margin: 0 0 4px; font-size: 0.85em; }
|.markdown-alert .octicon { fill: currentColor; vertical-align: middle; }
|.markdown-alert p:last-child { margin-bottom: 0; }
|.markdown-alert-note      { border-color: #0969da; background-color: #ddf4ff; color: #052e6b; }
|.markdown-alert-tip       { border-color: #1a7f37; background-color: #dafbe1; color: #0d5223; }
|.markdown-alert-important { border-color: #8250df; background-color: #f2e8ff; color: #3d1d8a; }
|.markdown-alert-warning   { border-color: #9a6700; background-color: #fff8c5; color: #6b4f00; }
|.markdown-alert-caution   { border-color: #cf222e; background-color: #ffebe9; color: #7a121b; }

|" + СтильПодсветкиСинтаксиса + "
					|";
	СтильКартинокHTML = ?(ЗначениеЗаполнено(СтильКартинок),
		"<style id=""rm-img-style"">" + СтильКартинок + "</style>",
		"");
	JSШаблонУправленияШиринойКартинок =
	"|    <script>
	|        function setImageMaxWidth(width){
	|            var styleEl = document.getElementById('rm-img-style');
	|            var css = '.wiki img, img { max-width: ' + width + '; height: auto; }';
	|            if (!styleEl){
	|                styleEl = document.createElement('style');
	|                styleEl.id = 'rm-img-style';
	|                document.head.appendChild(styleEl);
	|            }
	|            styleEl.innerHTML = css;
	|        }
	|    </script>
	|";
	ТекстHTML=
	"<html>
	|<head>
	|	<meta charset=""UTF-8"">
	|	 <script>
	|" + ТекстРазукрашивателя + "
	|	</script>
|    <script>
|" + БиблиотекаТекст + "
|	</script>
|    <script type=""text/javascript"">__JSОБОГАЩЕНИЕ__</script>
|    <script>
|
|        var markdownTexts={};
|		 var converter = new showdown.Converter();
|	     converter.setFlavor('github');
|
	|	     function clearTexts(){
	|            markdownTexts={};
	|        }
	|
|        function addText(key, text){
|            markdownTexts[key]=text;
|        }
|        function deleteText(key){
|            delete markdownTexts[key];
|        }
|
|        // Пост-обработка HTML после showdown: GitHub Alerts ([!NOTE], [!WARNING],
|        // [!TIP], [!IMPORTANT], [!CAUTION]) оборачиваются в
|        // <div class=""markdown-alert markdown-alert-{type}"">…</div>,
|        // заголовок [!TYPE|Заголовок] превращается в <p class=""markdown-alert-title"">…</p>.
|        // Зеркало серверной ОбработатьАлертыВHTML, чтобы алерты работали
|        // прямо в HTMLDocumentField формы элемента/группы без round-trip.
|        function gksiPostprocessAlerts(html) {
|            if (!html) return html;
|            var types = [
|                {name: 'WARNING',   cls: 'warning'},
|                {name: 'NOTE',      cls: 'note'},
|                {name: 'TIP',       cls: 'tip'},
|                {name: 'IMPORTANT', cls: 'important'},
|                {name: 'CAUTION',   cls: 'caution'}
|            ];
|            for (var i = 0; i < types.length; i++) {
|                var t = types[i];
|                var marker = '<p>[!' + t.name;
|                var newCls = 'markdown-alert markdown-alert-' + t.cls;
|                var idx = html.indexOf(marker);
|                while (idx !== -1) {
|                    var pStart = idx - 3;
|                    var pEnd = html.indexOf('</p>', idx);
|                    if (pStart >= 0 && pEnd !== -1) {
|                        var pInner = html.substring(pStart + 3, pEnd);
|                        var openMarker = '[!' + t.name;
|                        var mIdx = pInner.indexOf(openMarker);
|                        if (mIdx !== -1) {
|                            var closeIdx = pInner.indexOf(']', mIdx);
|                            if (closeIdx !== -1) {
|                                var inside = pInner.substring(
|                                    mIdx + openMarker.length, closeIdx);
|                                var title = (inside.charAt(0) === '|')
|                                    ? inside.substring(1).trim() : t.name;
|                                if (title === '') title = t.name;
|                                pInner = pInner.substring(0, mIdx)
|                                    + '<p class=""markdown-alert-title"">'
|                                    + title + '</p>'
|                                    + pInner.substring(closeIdx + 1);
|                            }
|                        }
|                        html = html.substring(0, pStart)
|                            + '<div class=""' + newCls + '"">'
|                            + pInner + '</div>'
|                            + html.substring(pEnd + 4);
|                    }
|                    idx = html.indexOf(marker, pStart + 1);
|                }
|            }
|            return html;
|        }
|
|		 function convertOneText(key,text){
|
|			 var newdiv = document.createElement('div');
|            newdiv.className = 'wiki';
|            newdiv.id = key;
|
|            var pre = typeof gksiPreprocessLinks === 'function' ? gksiPreprocessLinks(text) : text;
|            var html = converter.makeHtml(typeof gksiPreprocessAlerts === 'function' ? gksiPreprocessAlerts(pre) : pre);
|            html = typeof gksiPostprocessAlerts === 'function' ? gksiPostprocessAlerts(html) : html;
|            newdiv.innerHTML = html;
|
|            // ВРЕМЕННАЯ ДИАГНОСТИКА кликабельных ссылок (см. gksiDebugFooter).
|            var gksiDbg = typeof gksiDebugFooter === 'function' ? gksiDebugFooter(html, text) : null;
|            if (gksiDbg) newdiv.appendChild(gksiDbg);
|
|            return newdiv;
|    	   }
|
|		 function mdToHtml(text){
|            var pre = typeof gksiPreprocessLinks === 'function' ? gksiPreprocessLinks(text) : text;
|            var html = converter.makeHtml(typeof gksiPreprocessAlerts === 'function' ? gksiPreprocessAlerts(pre) : pre);
|            return typeof gksiPostprocessAlerts === 'function' ? gksiPostprocessAlerts(html) : html;
|    	   }
	|		 function htmlToMd(text){
	|           return converter.makeMarkdown(text);
	|      	 }
|        function markdownConvert(){
|            var container=document.getElementById('wiki-container');
|            container.innerHTML='';
|
|            for (var key in markdownTexts) {
|                if (markdownTexts.hasOwnProperty(key)) {
|                    var markText = markdownTexts[key];
|
|                	 var newdiv=convertOneText(key,markText);
|
|                    container.appendChild(newdiv);
|                }
|            }
|  			var elems= document.getElementsByTagName('code');
|
|			 for(var i = 0; i < elems.length; i++) {
|				hljs.highlightBlock(elems[i]);
|			}
|			if (typeof enrichTerms === 'function') enrichTerms();
|        }
|
|    </script>
|    <script type=""text/javascript"">__JSОБОГАЩЕНИЕ__</script>
|    <script type=""text/javascript"">window.__gksiTerms = __ТерминыJSON__;</script>
|    <script type=""text/javascript"">window.__gksiLinks = __СсылкиJSON__;</script>
|    <style>
|    html {
|		word-break: break-all;
|    	}
|		" + СтильCSS + "
|</style>
|" + СтильКартинокHTML + "
|" + JSШаблонУправленияШиринойКартинок + "
|</head>
|
|<body>
|    <div id=""wiki-container""></div>
|    <button id=""interactionButton"" style=""display: none"">Кнопка взаимодействия</button>
|</body>
|
|
|</html>
|";

	ТекстHTML = СтрЗаменить(ТекстHTML, "__ТерминыJSON__", ТерминыJSON);
	ТекстHTML = СтрЗаменить(ТекстHTML, "__СсылкиJSON__", СсылкиJSON);
	ТекстHTML = СтрЗаменить(ТекстHTML, "__JSОБОГАЩЕНИЕ__", JSОбогащение);

	Возврат ТекстHTML;
КонецФункции

// Возвращает список доступных вариантов подсветки синтаксиса.
//
// Возвращаемое значение:
//  Массив из Строка - имена вариантов.
Функция ВариантыПодсветкиСинтаксиса() Экспорт
	ТабДокумент=ПолучитьОбщийМакет("ГКСИ_ВариантыПодсветки");

	МассивВариантов=Новый Массив;
	Для НомерСтроки = 2 По ТабДокумент.ВысотаТаблицы Цикл
		Вариант=ТабДокумент.Область(НомерСтроки, 1, НомерСтроки, 1).Текст;
		Если Не ЗначениеЗаполнено(Вариант) Тогда
			Прервать;
		КонецЕсли;

		МассивВариантов.Добавить(Вариант);
	КонецЦикла;

	Возврат МассивВариантов;

КонецФункции

// Возвращает CSS-стиль для указанного варианта подсветки синтаксиса.
//
// Параметры:
//  ВариантПодсветки - Строка - имя варианта подсветки.
//
// Возвращаемое значение:
//  Строка - CSS-стиль.
Функция ТекстСтиляПодсветкиСинтаксиса(ВариантПодсветки) Экспорт
	СоответствиеСтилей=Новый Соответствие;

	ТабДокумент=ПолучитьОбщийМакет("ГКСИ_ВариантыПодсветки");

	Для НомерСтроки = 2 По ТабДокумент.ВысотаТаблицы Цикл
		Вариант=ТабДокумент.Область(НомерСтроки, 1, НомерСтроки, 1).Текст;
		Если Не ЗначениеЗаполнено(Вариант) Тогда
			Прервать;
		КонецЕсли;
		Стиль=ТабДокумент.Область(НомерСтроки, 2, НомерСтроки, 2).Текст;

		СоответствиеСтилей.Вставить(Вариант, Стиль);
	КонецЦикла;
	Стиль=СоответствиеСтилей[ВариантПодсветки];
	Если Стиль = Неопределено Тогда
		Стиль=СоответствиеСтилей["vs"];
	КонецЕсли;

	Возврат Стиль;
КонецФункции

// Вставляет на форму поле редактирования текста Markdown с предпросмотром.
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения - форма.
//  ГруппаЭлементовТекста - Произвольный - группа формы для размещения поля.
//  ПутьКДанным - Строка - путь к данным поля.
//  РазбиратьСсылки - Булево - Истина, если в предпросмотре нужно разбирать
//                    вики-ссылки [[...]] на группы и шаги демонстрационных
//                    сценариев. Для форм с текстом, не относящимся к сценариям
//                    (например, справка по синтаксису), карта ссылок не строится.
//  ВариантПодсветкиСинтаксиса - Строка - имя варианта подсветки синтаксиса.
//  ТолькоПросмотр - Булево - признак режима только просмотра.
//  ШиринаКартинок - Строка - CSS-ширина картинок.
//
Процедура ВставитьПолеРедактированияТекстаНаФорму(Форма, ГруппаЭлементовТекста, ПутьКДанным, РазбиратьСсылки,
	ВариантПодсветкиСинтаксиса = "ones", ТолькоПросмотр=Ложь, ШиринаКартинок = "") Экспорт

	ОписаниеТиповСтрока = Новый ОписаниеТипов("Строка");

	// Карта вики-ссылок на группы и шаги сценария — для кликабельных [[...]]
	// в предпросмотре Markdown. Ссылаться можно на любой узел любой инструкции
	// (форма вставки ссылки предлагает узлы всех инструкций, а один и тот же шаг
	// может входить в несколько инструкций), поэтому карта строится по всему
	// справочнику. Ссылки, не разрешённые по карте, показываются как «битые».
	КартаСсылок = Неопределено;
	Если РазбиратьСсылки Тогда
		КартаСсылок = ГКСИ_СсылкиСценариев.КартаСсылокСценариев();
	КонецЕсли;

	ПутьКДаннымБезЛишнего=ГКСИ_MarkdownКлиентСервер.ПолучитьПутьКДаннымБезЛишнего(ПутьКДанным);
	ПравильныйПутьКДанным=ПутьКДанным;
	
	//В маркдауне нужно сделать две закладки
	//редактирование и просмотр
	
	//1. Сначала добавляем страницы
	ИмяЭлементаСтраницРедактирования=ГКСИ_MarkdownКлиентСервер.ПолучитьИмяЭлементаПанелиСтраницРедактированияКомментария(ПутьКДанным);
	
	ОписаниеЭлемента=НовыйОписаниеРеквизитаЭлемента();
	ОписаниеЭлемента.Имя=ИмяЭлементаСтраницРедактирования;
	ОписаниеЭлемента.РодительЭлемента=ГруппаЭлементовТекста;

	ОписаниеЭлемента.Параметры.Тип=Тип("ГруппаФормы");
	ОписаниеЭлемента.Параметры.Вставить("Вид", ВидГруппыФормы.Страницы);
	ОписаниеЭлемента.Параметры.Вставить("АвтоМаксимальнаяШирина", Ложь);
	ОписаниеЭлемента.Параметры.Вставить("АвтоМаксимальнаяВысота", Ложь);
	ОписаниеЭлемента.Параметры.Вставить("ОтображениеСтраниц", ОтображениеСтраницФормы.ЗакладкиСнизу);
	ОписаниеЭлемента.Параметры.Вставить("ПоложениеЗаголовка", ПоложениеЗаголовкаЭлементаФормы.Нет);

	ОписаниеЭлемента.Действия.Вставить("ПриСменеСтраницы", "РМ_Подключаемый_ПриСменеСтраницыПоляКомментария");

	СтраницыРедактирования=СоздатьЭлементПоОписанию(Форма, ОписаниеЭлемента);
	
	Если Не ТолькоПросмотр Тогда
	//2. Страница редактирвания
		ОписаниеЭлемента=НовыйОписаниеРеквизитаЭлемента();
		ОписаниеЭлемента.Имя=ГКСИ_MarkdownКлиентСервер.ПолучитьИмяСтраницыРедактированияКомментария(ПутьКДанным);
		ОписаниеЭлемента.РодительЭлемента=СтраницыРедактирования;
		ОписаниеЭлемента.Заголовок="Редактирование";

		ОписаниеЭлемента.Параметры.Тип=Тип("ГруппаФормы");
		ОписаниеЭлемента.Параметры.Вставить("Вид", ВидГруппыФормы.Страница);
		ОписаниеЭлемента.Параметры.Вставить("АвтоМаксимальнаяШирина", Ложь);
		ОписаниеЭлемента.Параметры.Вставить("АвтоМаксимальнаяВысота", Ложь);

		СтраницаРедактирования=СоздатьЭлементПоОписанию(Форма, ОписаниеЭлемента);
	КонецЕсли;
	
	//3. Страница просмотра
	ИмяЭлементаСтраницыПросмотра=ГКСИ_MarkdownКлиентСервер.ПолучитьИмяСтраницыПросмотраКомментария(ПутьКДанным);
	
	ОписаниеЭлемента=НовыйОписаниеРеквизитаЭлемента();
	ОписаниеЭлемента.Имя=ИмяЭлементаСтраницыПросмотра;
	ОписаниеЭлемента.РодительЭлемента=СтраницыРедактирования;
	ОписаниеЭлемента.Заголовок="Просмотр";

	ОписаниеЭлемента.Параметры.Тип=Тип("ГруппаФормы");
	ОписаниеЭлемента.Параметры.Вставить("Вид", ВидГруппыФормы.Страница);
	ОписаниеЭлемента.Параметры.Вставить("АвтоМаксимальнаяШирина", Ложь);
	ОписаниеЭлемента.Параметры.Вставить("АвтоМаксимальнаяВысота", Ложь);

	СтраницаПросмотра=СоздатьЭлементПоОписанию(Форма, ОписаниеЭлемента);

	Если Не ТолькоПросмотр Тогда
	//4.1. Командная панель редактирования
		ДобавитьКнопкиВКоманднуюПанельРедактированияПоляMarkdown(Форма, СтраницаРедактирования, ПутьКДаннымБезЛишнего);
	
	//4.2. текст редактирования
		ОписаниеЭлемента=НовыйОписаниеРеквизитаЭлемента();
		ОписаниеЭлемента.Имя=ГКСИ_MarkdownКлиентСервер.ПрефиксЭлементовФормы() + ПутьКДаннымБезЛишнего;
		ОписаниеЭлемента.ПутьКДанным=ПравильныйПутьКДанным;
		ОписаниеЭлемента.РодительЭлемента=СтраницаРедактирования;

		ОписаниеЭлемента.Параметры.Вставить("АвтоМаксимальнаяШирина", Ложь);
		ОписаниеЭлемента.Параметры.Вставить("АвтоМаксимальнаяВысота", Ложь);
		ОписаниеЭлемента.Параметры.Вставить("ПоложениеЗаголовка", ПоложениеЗаголовкаЭлементаФормы.Нет);
		ОписаниеЭлемента.Параметры.Вставить("МногострочныйРежим", Истина);
		ОписаниеЭлемента.Параметры.Вставить("РасширенноеРедактирование", Истина);

		ТекстРедактирования=СоздатьЭлементПоОписанию(Форма, ОписаниеЭлемента);
	КонецЕсли;
	
	//5.1. Реквизит поля просмотра
	ПутьКПолюПросмотра=ГКСИ_MarkdownКлиентСервер.ПолучитьИмяЭлементаПросмотраКомментария(ПутьКДанным);

	НовыйРеквизит=Новый РеквизитФормы(ПутьКПолюПросмотра, ОписаниеТиповСтрока);

	МассивДобавляемыхРеквизитов=Новый Массив;
	МассивДобавляемыхРеквизитов.Добавить(НовыйРеквизит);
	
	// 5.1.а Реквизит таблицы присоединенных файлов
	ПутьКТаблицеПрисоединенныхФайлов=ГКСИ_MarkdownКлиентСервер.ИмяТаблицыПрисоединенныхФайлов(ПутьКДаннымБезЛишнего);
	Если Форма.Элементы.Найти(ПутьКТаблицеПрисоединенныхФайлов) = Неопределено Тогда

		НовыйРеквизит = Новый РеквизитФормы(ПутьКТаблицеПрисоединенныхФайлов, Новый ОписаниеТипов("ТаблицаЗначений"));
		МассивДобавляемыхРеквизитов.Добавить(НовыйРеквизит);
		
		НовыйРеквизит = Новый РеквизитФормы("Ссылка", Справочники.ТипВсеСсылки(), ПутьКТаблицеПрисоединенныхФайлов);
		МассивДобавляемыхРеквизитов.Добавить(НовыйРеквизит);

		НовыйРеквизит = Новый РеквизитФормы("ПутьКФайлу", ОписаниеТиповСтрока, ПутьКТаблицеПрисоединенныхФайлов);
		МассивДобавляемыхРеквизитов.Добавить(НовыйРеквизит);

		НовыйРеквизит = Новый РеквизитФормы("ИмяФайла", ОписаниеТиповСтрока, ПутьКТаблицеПрисоединенныхФайлов);
		МассивДобавляемыхРеквизитов.Добавить(НовыйРеквизит);
		НовыйРеквизит = Новый РеквизитФормы("Адрес", ОписаниеТиповСтрока, ПутьКТаблицеПрисоединенныхФайлов);
		МассивДобавляемыхРеквизитов.Добавить(НовыйРеквизит);
		НовыйРеквизит = Новый РеквизитФормы("ЭтоНовый", Новый ОписаниеТипов("Булево"), ПутьКТаблицеПрисоединенныхФайлов);
		МассивДобавляемыхРеквизитов.Добавить(НовыйРеквизит);

	КонецЕсли;

	Форма.ИзменитьРеквизиты(МассивДобавляемыхРеквизитов, );

	Форма[ПутьКПолюПросмотра]=СформироватьТекстHTMLДляТекстаMarkdown(ВариантПодсветкиСинтаксиса, ШиринаКартинок, ТекущийЯзык().КодЯзыка,
		ГКСИ_СсылкиСценариев.СсылкиJSONДляКлиента(КартаСсылок));
	
	//5.2. Поле формы просмтра
	ОписаниеЭлемента=НовыйОписаниеРеквизитаЭлемента();
	ОписаниеЭлемента.Имя=ПутьКПолюПросмотра;
	ОписаниеЭлемента.ПутьКДанным=ПутьКПолюПросмотра;
	ОписаниеЭлемента.РодительЭлемента=СтраницаПросмотра;

	ОписаниеЭлемента.Параметры.Вставить("Вид", ВидПоляФормы.ПолеHTMLДокумента);
	ОписаниеЭлемента.Параметры.Вставить("АвтоМаксимальнаяШирина", Ложь);
	ОписаниеЭлемента.Параметры.Вставить("АвтоМаксимальнаяВысота", Ложь);
	ОписаниеЭлемента.Параметры.Вставить("ПоложениеЗаголовка", ПоложениеЗаголовкаЭлементаФормы.Нет);

	ОписаниеЭлемента.Действия.Вставить("ПриНажатии", "РМ_Подключаемый_ПриНажатииПоляПросмотраКомментария");
	ОписаниеЭлемента.Действия.Вставить("ДокументСформирован", "РМ_Подключаемый_ДокументСформированПоляПросмотраКомментария");

	СтраницыПросмотра=СоздатьЭлементПоОписанию(Форма, ОписаниеЭлемента);
	
	// 5.3 Присоединенные файлы
	ОписаниеЭлемента=НовыйОписаниеРеквизитаЭлемента();
	ОписаниеЭлемента.Имя=ГКСИ_MarkdownКлиентСервер.ИмяГруппыНовыхПрисоединенныхФайлов(ПутьКДаннымБезЛишнего);
	ОписаниеЭлемента.РодительЭлемента=СтраницаРедактирования;
	ОписаниеЭлемента.Заголовок="Новые файлы";

	ОписаниеЭлемента.Параметры.Тип=Тип("ГруппаФормы");
	ОписаниеЭлемента.Параметры.Вставить("Вид", ВидГруппыФормы.ОбычнаяГруппа);
	ОписаниеЭлемента.Параметры.Вставить("АвтоМаксимальнаяШирина", Ложь);
	ОписаниеЭлемента.Параметры.Вставить("АвтоМаксимальнаяВысота", Ложь);
	ОписаниеЭлемента.Параметры.Вставить("Поведение", ПоведениеОбычнойГруппы.Свертываемая);

	ГруппаНовыеПрисоединенныеФайлы=СоздатьЭлементПоОписанию(Форма, ОписаниеЭлемента);
	
	Если ТолькоПросмотр Тогда
		Форма.Элементы[ИмяЭлементаСтраницРедактирования].ОтображениеСтраниц=ОтображениеСтраницФормы.Нет;
		Форма.Элементы[ИмяЭлементаСтраницРедактирования].ТекущаяСтраница=Форма.Элементы[ИмяЭлементаСтраницыПросмотра];
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ДобавитьКнопкиВКоманднуюПанельРедактированияПоляMarkdown(Форма, ГруппаПоляРедактирования,
	ПутьКДаннымРедактирования, ЭтоВебКлиент = Ложь)

	ОписаниеЭлемента=НовыйОписаниеРеквизитаЭлемента();
	ОписаниеЭлемента.Имя=ГКСИ_MarkdownКлиентСервер.ПрефиксЭлементовФормы()+"КомманднаяПанель_Редактирование_" + ПутьКДаннымРедактирования;
	ОписаниеЭлемента.РодительЭлемента=ГруппаПоляРедактирования;

	ОписаниеЭлемента.Параметры.Тип=Тип("ГруппаФормы");
	ОписаниеЭлемента.Параметры.Вставить("Вид", ВидГруппыФормы.КоманднаяПанель);

	КоманднаяПанель=СоздатьЭлементПоОписанию(Форма, ОписаниеЭлемента);
	
	//ИЗменения шрифта
	ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDЖирный", "Жирный", БиблиотекаКартинок.ГКСИ_Жирный,
		Форма, КоманднаяПанель, ПутьКДаннымРедактирования);
	ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDКурсив", "Курсив", БиблиотекаКартинок.ГКСИ_Курсив,
		Форма, КоманднаяПанель, ПутьКДаннымРедактирования);
	ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDЗачеркнутый", "Зачеркнутый",
		БиблиотекаКартинок.ГКСИ_Зачеркнутый, Форма, КоманднаяПанель, ПутьКДаннымРедактирования);	

	//Заголовки
	ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDЗаголовок1", "Заголовок 1",
		БиблиотекаКартинок.ГКСИ_ЗаголовокH1, Форма, КоманднаяПанель, ПутьКДаннымРедактирования);
	ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDЗаголовок2", "Заголовок 2",
		БиблиотекаКартинок.ГКСИ_ЗаголовокH2, Форма, КоманднаяПанель, ПутьКДаннымРедактирования);
	ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDЗаголовок3", "Заголовок 3",
		БиблиотекаКартинок.ГКСИ_ЗаголовокH3, Форма, КоманднаяПанель, ПутьКДаннымРедактирования);	

	//Всякое
	ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDЦитата", "Цитата", БиблиотекаКартинок.ГКСИ_Цитата,
		Форма, КоманднаяПанель, ПутьКДаннымРедактирования);
	ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDСсылка", "Ссылка", БиблиотекаКартинок.ГКСИ_Ссылка,
		Форма, КоманднаяПанель, ПутьКДаннымРедактирования);
	ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDПрограммныйКод", "Вставить код",
		БиблиотекаКартинок.ГКСИ_ПрограммныйКод, Форма, КоманднаяПанель, ПутьКДаннымРедактирования);	

	//Списки
	ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDМаркерыСписок", "Маркированный список",
		БиблиотекаКартинок.ГКСИ_МаркерыСписок, Форма, КоманднаяПанель, ПутьКДаннымРедактирования);
	ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDНумерованныйСписок", "Нумерованный список",
		БиблиотекаКартинок.ГКСИ_НумерованныйСписок, Форма, КоманднаяПанель, ПутьКДаннымРедактирования);
	ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDСписокЗадач", "Список задач",
		БиблиотекаКартинок.ГКСИ_СписокЗадач, Форма, КоманднаяПанель, ПутьКДаннымРедактирования);
	ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDТаблица", "Вставить таблицу",
		БиблиотекаКартинок.ГКСИ_Таблица, Форма, КоманднаяПанель, ПутьКДаннымРедактирования);

	Если Не ЭтоВебКлиент Тогда
		СочетаниеКлавишВставкиКартинки=Новый СочетаниеКлавиш(Клавиша.Z, Ложь, Истина, Истина);
		ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDВставитьИзображениеИзБуфераОбмена",
			"Изображение из буфера", БиблиотекаКартинок.ГКСИ_ВставитьКартинкуИзБуфера, Форма, КоманднаяПанель,
			ПутьКДаннымРедактирования, СочетаниеКлавишВставкиКартинки);
	КонецЕсли;

	ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDДобавитьФайл", "Добавить файл",
		БиблиотекаКартинок.ГКСИ_Скрепка, Форма, КоманднаяПанель, ПутьКДаннымРедактирования);	
	
	ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDОткрытьСинтаксис", "Добавить файл",
		БиблиотекаКартинок.ГКСИ_Синтаксис, Форма, КоманднаяПанель, ПутьКДаннымРедактирования);	

	ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDГлоссарий", "Термин глоссария",
		БиблиотекаКартинок.ГКСИ_Ссылка, Форма, КоманднаяПанель, ПутьКДаннымРедактирования);

	ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown("КомандаMDСсылкаНаУзел", "Ссылка на группу или шаг",
		БиблиотекаКартинок.ГКСИ_Ссылка, Форма, КоманднаяПанель, ПутьКДаннымРедактирования);

	// подменю для вставки
	ОписаниеЭлемента=НовыйОписаниеРеквизитаЭлемента();
	ОписаниеЭлемента.Имя=ГКСИ_MarkdownКлиентСервер.ПрефиксЭлементовФормы()+"ПодменюВставитьЗагруженноеИзображение" + "_" + ПутьКДаннымРедактирования;
	ОписаниеЭлемента.РодительЭлемента=КоманднаяПанель;
	ОписаниеЭлемента.Заголовок="Вставить...";

	ОписаниеЭлемента.Параметры.Тип=Тип("ГруппаФормы");
	ОписаниеЭлемента.Параметры.Вставить("Вид", ВидГруппыФормы.Подменю);

	СоздатьЭлементПоОписанию(Форма, ОписаниеЭлемента);

КонецПроцедуры

Процедура ДобавитьКомандуНаКоманднуюПанельРедактированияMarkdown(ИмяКоманды, Заголовок, Картинка, Форма,
	КоманднаяПанель, ПутьКДаннымРедактирования, СочетаниеКлавиш = Неопределено)

	НовыйОписаниеКомандыКнопки=НовыйОписаниеКомандыКнопки();
	НовыйОписаниеКомандыКнопки.Имя=ГКСИ_MarkdownКлиентСервер.ПрефиксЭлементовФормы()+ИмяКоманды + "_" + ПутьКДаннымРедактирования;
	НовыйОписаниеКомандыКнопки.Действие="РМ_Подключаемый_ОбработкаКомандыПоляКомментария";
	НовыйОписаниеКомандыКнопки.ИмяКоманды=ГКСИ_MarkdownКлиентСервер.ПрефиксЭлементовФормы()+ИмяКоманды + "_" + ПутьКДаннымРедактирования;
	НовыйОписаниеКомандыКнопки.Заголовок=Заголовок;
	НовыйОписаниеКомандыКнопки.Картинка=Картинка;
	НовыйОписаниеКомандыКнопки.РодительЭлемента=КоманднаяПанель;
	НовыйОписаниеКомандыКнопки.СочетаниеКлавиш=СочетаниеКлавиш;

	СоздатьКомандуПоОписанию(Форма, НовыйОписаниеКомандыКнопки);
	СоздатьКнопкуПоОписанию(Форма, НовыйОписаниеКомандыКнопки);

КонецПроцедуры

Процедура ВывестиЭлементыПрисоединенногоФайлаНаФорму(Форма, ИмяФайла, ИдентификаторСтроки, ПутьКДаннымБезЛишнего) Экспорт

	Элементы = Форма.Элементы;

	ИмяГруппыНовыхФайлов=ГКСИ_MarkdownКлиентСервер.ИмяГруппыНовыхПрисоединенныхФайлов(ПутьКДаннымБезЛишнего);
	ГруппаНовыеПрисоединенныеФайлы = Элементы.Найти(ИмяГруппыНовыхФайлов);

	ИмяГруппыТекФайла=ГКСИ_MarkdownКлиентСервер.ИмяГруппыНовогоПрисоединеногоФайла(ПутьКДаннымБезЛишнего,
		ИдентификаторСтроки);
	ГруппаТекФайла = Элементы.Добавить(ИмяГруппыТекФайла, Тип("ГруппаФормы"), ГруппаНовыеПрисоединенныеФайлы);
	ГруппаТекФайла.Вид         = ВидГруппыФормы.ОбычнаяГруппа;
	ГруппаТекФайла.Группировка = ГруппировкаПодчиненныхЭлементовФормы.ГоризонтальнаяВсегда;
	ГруппаТекФайла.ОтображатьЗаголовок = Ложь;

	ИмяЭлемента=ГКСИ_MarkdownКлиентСервер.ИмяЭлементаНадписиНовогоПрисоединеногоФайла(ПутьКДаннымБезЛишнего,
		ИдентификаторСтроки);
	Эскиз = Элементы.Добавить(ИмяЭлемента, Тип("ДекорацияФормы"), ГруппаТекФайла);
//	Эскиз.Вид = ВидПоляФормы.ПолеНадписи;
//	Эскиз.ПутьКДанным = "ТаблицаПрисоединенныхФайлов["+ИндексСтроки+"].Адрес";	
	Эскиз.Заголовок = ИмяФайла;
//	Эскиз.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Лево;
//	Эскиз.РазмерКартинки = РазмерКартинки.Пропорционально;
//	Эскиз.РастягиватьПоГоризонтали = Ложь;
//	Эскиз.РастягиватьПоВертикали = Ложь;
//	Эскиз.Ширина = 10;
//	Эскиз.Высота = 4;

	ИмяГруппыКоманд=ГКСИ_MarkdownКлиентСервер.ИмяГруппыКомандНовогоПрисоединеногоФайла(ПутьКДаннымБезЛишнего,
		ИдентификаторСтроки);
	ГруппаКоманд = Элементы.Добавить(ИмяГруппыКоманд, Тип("ГруппаФормы"), ГруппаТекФайла);
	ГруппаКоманд.Вид         = ВидГруппыФормы.ОбычнаяГруппа;
	ГруппаКоманд.Группировка = ГруппировкаПодчиненныхЭлементовФормы.ГоризонтальнаяВсегда;
	ГруппаКоманд.ОтображатьЗаголовок = Ложь;
	
	// удалить
	ИмяКомандыУдалить = ГКСИ_MarkdownКлиентСервер.ИмяКомандыУдалитьНовогоПрисоединеногоФайла(ПутьКДаннымБезЛишнего,
		ИдентификаторСтроки);

	Команда = Форма.Команды.Добавить(ИмяКомандыУдалить);
	Команда.Заголовок  = "Удалить";
	Команда.Действие   = "РМ_Подключаемый_УдалитьНовыйПрисоединенныйФайл";
	Команда.Картинка   = БиблиотекаКартинок.Удалить;
	Команда.ИзменяетСохраняемыеДанные = Истина;
	Команда.Отображение = ОтображениеКнопки.Картинка;

	КнопкаУдалить = Элементы.Добавить(ИмяКомандыУдалить, Тип("КнопкаФормы"), ГруппаКоманд);
	КнопкаУдалить.ИмяКоманды = ИмяКомандыУдалить;
	
	// открыть
	ИмяКомандыОткрыть = ГКСИ_MarkdownКлиентСервер.ИмяКомандыОткрытьНовогоПрисоединеногоФайла(ПутьКДаннымБезЛишнего,
		ИдентификаторСтроки);

	Команда = Форма.Команды.Добавить(ИмяКомандыОткрыть);
	Команда.Заголовок  = "Открыть";
	Команда.Действие   = "РМ_Подключаемый_ОткрытьНовыйПрисоединенныйФайл";
	Команда.Картинка   = БиблиотекаКартинок.ПоказатьДанные;
	Команда.Отображение = ОтображениеКнопки.Картинка;

	КнопкаУдалить = Элементы.Добавить(ИмяКомандыОткрыть, Тип("КнопкаФормы"), ГруппаКоманд);
	КнопкаУдалить.ИмяКоманды = ИмяКомандыОткрыть;
	
	// вставить загруженное изображение
	//Доступно только если формат загружаемого файла является картинкой
	ИмяКомандыВставить = ГКСИ_MarkdownКлиентСервер.ИмяКомандыВставитьНовогоПрисоединеногоФайла(ПутьКДаннымБезЛишнего,
		ИдентификаторСтроки);

	Команда = Форма.Команды.Добавить(ИмяКомандыВставить);
	Команда.Заголовок  = ИмяФайла;
	Команда.Действие   = "РМ_Подключаемый_ОбработкаКомандыПоляКомментария";
	Команда.Отображение = ОтображениеКнопки.Текст;

	Подменю = Элементы.Найти(ГКСИ_MarkdownКлиентСервер.ПрефиксЭлементовФормы()+"ПодменюВставитьЗагруженноеИзображение_" + ПутьКДаннымБезЛишнего);

	КнопкаВставить = Элементы.Добавить(ИмяКомандыВставить, Тип("КнопкаФормы"), Подменю);
	КнопкаВставить.ИмяКоманды = ИмяКомандыВставить;

КонецПроцедуры

//@skip-warning
Функция ПолучитьСсылкуНаПрисоединенныйФайлПоИдентификатору(Идентификатор) Экспорт
//	Возврат Справочники.ЗадачаПрисоединенныеФайлы.ПолучитьСсылку(Идентификатор);
КонецФункции

Процедура УдалитьНовыеПрисоединенныеФайлыСФормыПослеЗаписи(Форма,ПутьКДанным) Экспорт
	
	Элементы = Форма.Элементы;
	
	ПутьКДаннымБезЛишнего=ГКСИ_MarkdownКлиентСервер.ПолучитьПутьКДаннымБезЛишнего(ПутьКДанным);
	ИмяТаблицыПрисоединенныхФайлов=ГКСИ_MarkdownКлиентСервер.ИмяТаблицыПрисоединенныхФайлов(ПутьКДаннымБезЛишнего);

	СтрокиФайлов = Форма[ИмяТаблицыПрисоединенныхФайлов].НайтиСтроки(Новый Структура("ЭтоНовый", Истина));
	Для Каждого СтрокаФайла Из СтрокиФайлов Цикл
		СтрокаФайла.ЭтоНовый = Ложь;
	КонецЦикла;
	
	ИмяГруппыНовыхПрисоединенныхФайлов=ГКСИ_MarkdownКлиентСервер.ИмяГруппыНовыхПрисоединенныхФайлов(ПутьКДаннымБезЛишнего);
	ГруппаНовыеПрисоединенныеФайлы = Элементы.Найти(ИмяГруппыНовыхПрисоединенныхФайлов);
	
	Если ГруппаНовыеПрисоединенныеФайлы <> Неопределено Тогда
		Для Каждого ГруппаФайла Из ГруппаНовыеПрисоединенныеФайлы.ПодчиненныеЭлементы Цикл
			Элементы.Удалить(ГруппаФайла);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаписатьНовыеПрисоединенныеФайлы(Форма, ВладелецФайлов,ПутьКДанным,Предмет=Неопределено) Экспорт
	ПутьКДаннымБезЛишнего=ГКСИ_MarkdownКлиентСервер.ПолучитьПутьКДаннымБезЛишнего(ПутьКДанным);

	ДанныеПрисоединенныхФайлов = ГКСИ_MarkdownКлиентСервер.ДанныеПрисоединенныхФайлов(Форма, ПутьКДаннымБезЛишнего);

	Для Каждого СтрокаФайла Из ДанныеПрисоединенныхФайлов Цикл
		
		// при удалении не сохраненного файла адрес в хранилище очищается
		Если Не ЗначениеЗаполнено(СтрокаФайла.Адрес) ИЛИ НЕ СтрокаФайла.ЭтоНовый Тогда
			Продолжить;
		КонецЕсли;
		
		ЧастиИмениФайла = ГКСИ_MarkdownКлиентСервер.РазложитьПолноеИмяФайла(СтрокаФайла.ПутьКФайлу);
		РасширениеБезТочки = СтрЗаменить(ЧастиИмениФайла.Расширение, ".", "");
		ИмяБезРасширения = ЧастиИмениФайла.ИмяБезРасширения;
		
		ПараметрыФайла = Новый Структура;
		ПараметрыФайла.Вставить("ВладелецФайлов", ВладелецФайлов);
		ПараметрыФайла.Вставить("ИмяБезРасширения", ИмяБезРасширения);
		ПараметрыФайла.Вставить("РасширениеБезТочки", РасширениеБезТочки);
		ПараметрыФайла.Вставить("ВремяИзменения", Неопределено);
		ПараметрыФайла.Вставить("ВремяИзмененияУниверсальное", Неопределено);
		
		ГКСИ_MarkdownПереопределяемый.ЗаписатьПрисоединенныйФайлВБазу(ПараметрыФайла,СтрокаФайла.Адрес,Форма, ПутьКДанным,Предмет);
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ПрочитатьПрисоединенныеФайлы(Форма, ВладелецФайлов, ПутьКДанным) Экспорт
	
	ПутьКДаннымБезЛишнего=ГКСИ_MarkdownКлиентСервер.ПолучитьПутьКДаннымБезЛишнего(ПутьКДанным);
	ИмяТаблицыПрисоединенныхФайлов=ГКСИ_MarkdownКлиентСервер.ИмяТаблицыПрисоединенныхФайлов(ПутьКДаннымБезЛишнего);

	Форма[ИмяТаблицыПрисоединенныхФайлов].Очистить();

	ВсеПрисоединенныеФайлы = Новый Массив;
	ГКСИ_MarkdownПереопределяемый.ЗаполнитьПрисоединенныеФайлыКОбъекту(ВсеПрисоединенныеФайлы,ВладелецФайлов,Форма,ПутьКДанным);
	
	Если ВсеПрисоединенныеФайлы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	УникальныйИдентификатор = Форма.УникальныйИдентификатор;
	ДополнительныеПараметры = Новый Структура("ИдентификаторФормы", УникальныйИдентификатор);
	
	Для Каждого Файл Из ВсеПрисоединенныеФайлы Цикл
		
		ДанныеФайла = Неопределено;
		ГКСИ_MarkdownПереопределяемый.ПриПолученииДанныхФайла(ДанныеФайла,Файл,УникальныйИдентификатор,Форма,ВладелецФайлов,ПутьКДанным);
		
		Если ДанныеФайла=Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		СтрокаФайла = Форма[ИмяТаблицыПрисоединенныхФайлов].Добавить();
		СтрокаФайла.ИмяФайла = ДанныеФайла.ИмяФайла;
		СтрокаФайла.Адрес = ДанныеФайла.СсылкаНаДвоичныеДанныеФайла;
		СтрокаФайла.ЭтоНовый = Ложь;
		СтрокаФайла.Ссылка = Файл;
		
	КонецЦикла;
	
КонецПроцедуры


Функция НовыйОписаниеРеквизитаЭлемента() Экспорт
	СтруктураРеквизита = Новый Структура;
	
	СтруктураРеквизита.Вставить("СоздаватьРеквизит", Истина);
	СтруктураРеквизита.Вставить("Имя", "");
	СтруктураРеквизита.Вставить("ОписаниеТипов", Новый ОписаниеТипов("Строка", , , , Новый КвалификаторыСтроки(10)));
	СтруктураРеквизита.Вставить("ПутьКДанным", "");
	СтруктураРеквизита.Вставить("Заголовок", "");

	СтруктураРеквизита.Вставить("СоздаватьЭлемент", Истина);
	СтруктураРеквизита.Вставить("РодительЭлемента", Неопределено);
	СтруктураРеквизита.Вставить("ПередЭлементом", Неопределено);
	СтруктураРеквизита.Вставить("МногострочныйРежим", Неопределено);
	СтруктураРеквизита.Вставить("РасширенноеРедактирование", Неопределено);
	СтруктураРеквизита.Вставить("РастягиватьПоГоризонтали", Неопределено);
	СтруктураРеквизита.Вставить("РастягиватьПоВертикали", Неопределено);
	СтруктураРеквизита.Вставить("Параметры", НовыйПараметрыРеквизита());
	СтруктураРеквизита.Вставить("Действия", Новый Структура);
	Возврат СтруктураРеквизита;

КонецФункции

Функция НовыйПараметрыРеквизита()

	Параметры = Новый Структура;

	Параметры.Вставить("Тип", Тип("ПолеФормы"));
	Параметры.Вставить("Вид_ПоУмолчанию", ВидПоляФормы.ПолеВвода);

	Возврат Параметры;

КонецФункции

Функция НовыйОписаниеКомандыКнопки() Экспорт
	Структура = Новый Структура;

	Структура.Вставить("СоздаватьКоманду", Истина);
	Структура.Вставить("СоздаватьКнопку", Истина);

	Структура.Вставить("Имя", "");
	Структура.Вставить("Действие", "");
	Структура.Вставить("ИмяКоманды", "");
	Структура.Вставить("ЭтоГиперссылка", Ложь);
	Структура.Вставить("РодительЭлемента", Неопределено);
	Структура.Вставить("ПередЭлементом", Неопределено);
	Структура.Вставить("Заголовок", "");
	Структура.Вставить("Подсказка", "");
	Структура.Вставить("СочетаниеКлавиш", Неопределено);
	Структура.Вставить("Картинка", Неопределено);

	Возврат Структура;
КонецФункции

Функция СоздатьКомандуПоОписанию(Форма, ОписаниеКоманды) Экспорт
	Если Не ОписаниеКоманды.СоздаватьКоманду Тогда
		Возврат Неопределено;
	КонецЕсли;
	Команда = Форма.Команды.Добавить(ОписаниеКоманды.Имя);
	Команда.Заголовок  = ОписаниеКоманды.Заголовок;
	Команда.Подсказка  = ОписаниеКоманды.Подсказка;
	Команда.Действие   = ОписаниеКоманды.Действие;
	Команда.Картинка   = ОписаниеКоманды.Картинка;
	Если ОписаниеКоманды.СочетаниеКлавиш <> Неопределено Тогда
		Команда.СочетаниеКлавиш = ОписаниеКоманды.СочетаниеКлавиш;
	КонецЕсли;

	Возврат Команда;
КонецФункции

Функция СоздатьЭлементПоОписанию(Форма, ОписаниеРеквизита) Экспорт
	Если Не ОписаниеРеквизита.СоздаватьЭлемент Тогда
		Возврат Неопределено;
	КонецЕсли;

	ЭлементФормы = Форма.Элементы.Вставить(ИмяТаблицыПоляФормы(Форма, ОписаниеРеквизита.РодительЭлемента)
		+ ОписаниеРеквизита.Имя, ОписаниеРеквизита.Параметры.Тип, ЭлементФормы(Форма,
		ОписаниеРеквизита.РодительЭлемента), ЭлементФормы(Форма, ОписаниеРеквизита.ПередЭлементом));

	ЭлементФормы.Заголовок = ОписаниеРеквизита.Заголовок;

	Если Тип(ЭлементФормы) = Тип("ПолеФормы") Тогда
		ЭлементФормы.Вид = ОписаниеРеквизита.Параметры.Вид_ПоУмолчанию;
		Попытка
			Если ТипЗнч(Реквизит(Форма, ОписаниеРеквизита.Имя, ОписаниеРеквизита.ПутьКДанным)) = Тип("Булево") Тогда
				ЭлементФормы.Вид = ВидПоляФормы.ПолеФлажка;
			КонецЕсли;
		Исключение
			ЗаписьЖурналаРегистрации("РМ_MarkdownСервер.ОпределениеВидаПоляФормы",
				УровеньЖурналаРегистрации.Предупреждение,,,
				ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		КонецПопытки;
	КонецЕсли;

	ЗаполнитьЗначенияСвойств(ЭлементФормы, ОписаниеРеквизита.Параметры);

	Если Тип(ЭлементФормы) = Тип("ПолеФормы") Тогда
		Если ЗначениеЗаполнено(ОписаниеРеквизита.ПутьКДанным) Тогда
			ЭлементФормы.ПутьКДанным = ОписаниеРеквизита.ПутьКДанным;
		Иначе
			ЭлементФормы.ПутьКДанным = ОписаниеРеквизита.Имя;
		КонецЕсли;

		Если ОписаниеРеквизита.МногострочныйРежим <> Неопределено Тогда
			ЭлементФормы.МногострочныйРежим=ОписаниеРеквизита.МногострочныйРежим;
		КонецЕсли;
		Если ОписаниеРеквизита.РасширенноеРедактирование <> Неопределено Тогда
			ЭлементФормы.РасширенноеРедактирование=ОписаниеРеквизита.РасширенноеРедактирование;
		КонецЕсли;

	КонецЕсли;
	Если ОписаниеРеквизита.РастягиватьПоГоризонтали <> Неопределено Тогда
		ЭлементФормы.РастягиватьПоГоризонтали=ОписаниеРеквизита.РастягиватьПоГоризонтали;
	КонецЕсли;
	Если ОписаниеРеквизита.РастягиватьПоВертикали <> Неопределено Тогда
		ЭлементФормы.РастягиватьПоВертикали=ОписаниеРеквизита.РастягиватьПоВертикали;
	КонецЕсли;

	Для Каждого Действие Из ОписаниеРеквизита.Действия Цикл
		ЭлементФормы.УстановитьДействие(Действие.Ключ, Действие.Значение);
	КонецЦикла;
	Возврат ЭлементФормы;
КонецФункции

Функция СоздатьКнопкуПоОписанию(Форма, ОписаниеКнопки) Экспорт
	Если Не ОписаниеКнопки.СоздаватьКнопку Тогда
		Возврат Неопределено;
	КонецЕсли;

	Кнопка = Форма.Элементы.Вставить(ОписаниеКнопки.Имя, Тип("КнопкаФормы"), ЭлементФормы(Форма,
		ОписаниеКнопки.РодительЭлемента), ЭлементФормы(Форма, ОписаниеКнопки.ПередЭлементом));
	Если Не ОписаниеКнопки.СоздаватьКоманду Тогда
		Кнопка.Заголовок = ОписаниеКнопки.Заголовок;
	КонецЕсли;
	Если ОписаниеКнопки.ЭтоГиперссылка = Ложь Тогда
		Если ЭтоКнопкаКоманднойПанели(Форма, ОписаниеКнопки.РодительЭлемента) Тогда
			Кнопка.Вид = ВидКнопкиФормы.ОбычнаяКнопка;
		Иначе
			Кнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
		КонецЕсли;
	Иначе
		Если ЭтоКнопкаКоманднойПанели(Форма, ОписаниеКнопки.РодительЭлемента) Тогда
			Кнопка.Вид = ВидКнопкиФормы.Гиперссылка;
		Иначе
			Кнопка.Вид = ВидКнопкиФормы.ГиперссылкаКоманднойПанели;
		КонецЕсли;
	КонецЕсли;
	Кнопка.ИмяКоманды = ОписаниеКнопки.ИмяКоманды;

КонецФункции

Функция ЭтоКнопкаКоманднойПанели(Форма, Знач РодительКнопки)
	ИмяТипаУправляемаяФорма = "УправляемаяФорма";
	Если РодительКнопки = Неопределено Тогда
		Возврат Ложь;
	ИначеЕсли РодительКнопки = Форма.КоманднаяПанель Тогда
		Возврат Истина;
	ИначеЕсли ТипЗнч(РодительКнопки) = Тип(ИмяТипаУправляемаяФорма) Тогда
		Возврат Ложь;
	Иначе
		РодительКнопки = ЭлементФормы(Форма, РодительКнопки);
		Возврат ЭтоКнопкаКоманднойПанели(Форма, РодительКнопки.Родитель);
	КонецЕсли;
КонецФункции

Функция ИмяТаблицыПоляФормы(Форма, Знач РодительЭлемента)
	ИмяТипаУправляемаяФорма = "УправляемаяФорма";
	Если РодительЭлемента = Неопределено Тогда
		Возврат "";
	ИначеЕсли ТипЗнч(РодительЭлемента) = Тип("ТаблицаФормы") Тогда
		Возврат РодительЭлемента.Имя;
	ИначеЕсли ТипЗнч(РодительЭлемента) = Тип(ИмяТипаУправляемаяФорма) Тогда
		Возврат "";
	Иначе
		РодительКнопки = ЭлементФормы(Форма, РодительЭлемента);
		Возврат ИмяТаблицыПоляФормы(Форма, РодительЭлемента.Родитель);
	КонецЕсли;
КонецФункции

// Серверный preprocessing блоков GitHub-style (\x5B!NOTE], \[!WARNING] и т.д.)
// в HTML-описаниях альбома. Ищет обёртки <div class="markdown-alert">...</div>
// и добавляет к ним правильный класс markdown-alert-{TYPE}, чтобы сработали
// CSS-стили .markdown-alert-{TYPE} (определены в <head> документа альбома).
//
// Зачем на сервере: JS-preprocessing через gksiPreprocessAlerts не сработает
// в выгруженном HTML-файле альбома (JS в HTMLDocumentField 1С работает не
// всегда и без DevTools сложно диагностировать). Серверный preprocessing
// работает в любом окружении — выгруженный HTML, печать, отправка по почте.
//
// Параметры:
//  Текст - Строка - HTML-описание для обработки.
//
// Возвращаемое значение:
//  Строка - HTML с правильно проставленными классами markdown-alert-{TYPE}.
Функция ОбработатьАлертыВHTML(Текст) Экспорт
	Если НЕ ЗначениеЗаполнено(Текст) Тогда
		Возврат Текст;
	КонецЕсли;

	ТекстДо = Текст;

	// Подсчёт совпадений до замены (чтобы зафиксировать в журнале, сколько
	// было найдено блоков каждого типа).
	МассивТипов = Новый Массив;
	МассивТипов.Добавить("WARNING");
	МассивТипов.Добавить("NOTE");
	МассивТипов.Добавить("TIP");
	МассивТипов.Добавить("IMPORTANT");
	МассивТипов.Добавить("CAUTION");

	// Подсчёт вхождений через простую подстроку (без regex — обходит ошибку
	// ICU regex на [\s\S]*?).
	СчётчикСовпаденийПоТипам = "";
	Для Каждого ТекТип Из МассивТипов Цикл
		Колво = СтрЧислоВхождений(Текст, "[!" + ТекТип);
		Если Колво > 0 Тогда
			СчётчикСовпаденийПоТипам = СчётчикСовпаденийПоТипам + ТекТип + "=" + Строка(Колво) + ",";
		КонецЕсли;
	КонецЦикла;

	// Фрагмент первого совпадения (для диагностики, если что-то пошло не так).
	ФрагментДляЛога = "";
	Поз = СтрНайти(Текст, "<blockquote>");
	Если Поз > 0 Тогда
		ФрагментДляЛога = Сред(Текст, Поз, Мин(400, СтрДлина(Текст) - Поз + 1));
	КонецЕсли;

	ЗаписьЖурналаРегистрации(
		"ГКСИ.MarkdownServer.Alerts.ServerPreprocess",
		УровеньЖурналаРегистрации.Информация, , ,
		"START len=" + Строка(СтрДлина(Текст))
		+ "; byType=" + СчётчикСовпаденийПоТипам
		+ "; firstBlockquote=" + ФрагментДляЛога);

	// 0. Нормализация: гарантируем, что каждый маркер [!TYPE] находится
	//    в начале своего <p>. Нужно для HTML, который пришёл НЕ из
	//    MarkdownВHTML (например, из формы элемента/группы через showdown.js
	//    или из альбома процессов): там [!CAUTION] может оказаться в середине
	//    большого <p> после <br>. ЗаменитьОбёрткуНаDiv ниже ищет точное
	//    "<p>[!TYPE" и без этой нормализации такой блок пропускает
	//    (лог показывал byType=CAUTION=1, но delta=0; changed=Нет).
	//    Идемпотентно: если маркер уже стоит в начале <p>, ничего не меняется.
	Текст = ОбеспечитьНачалоПараграфаДляМаркеровАлертов(Текст);

	// 1. Showdown-вывод: <blockquote>...[!TYPE]...</blockquote> — заменяем обёртку
	//    на <div class="markdown-alert markdown-alert-TYPE">. Это покрывает случай,
	//    когда описание было обработано showdown до нашего preprocessing и блок
	//    превратился в стандартный blockquote (CSS .markdown-alert-* к нему не
	//    применяется). Замену делаем простым обходом строки без regex — обходим
	//    нестабильности ICU regex в BSL на <blockquote>...</blockquote>.
	Текст = ЗаменитьОбёрткуНаDiv(Текст, "WARNING", "warning");
	Текст = ЗаменитьОбёрткуНаDiv(Текст, "NOTE", "note");
	Текст = ЗаменитьОбёрткуНаDiv(Текст, "TIP", "tip");
	Текст = ЗаменитьОбёрткуНаDiv(Текст, "IMPORTANT", "important");
	Текст = ЗаменитьОбёрткуНаDiv(Текст, "CAUTION", "caution");

	// 1a. Backfill: HTML, обработанный предыдущими версиями (v2.32.7+), уже
	//     содержит <div class="markdown-alert markdown-alert-{type}">, но БЕЗ
	//     inline-style. ЗаменитьОбёрткуНаDiv его не находит (нет маркера
	//     <p>[!TYPE…]), поэтому прогоняем второй проход: находим <div>
	//     без style и дописываем его. Идемпотентно — для HTML с уже
	//     проставленным style замена не срабатывает.
	Текст = ДобавитьInlineСтилиКАлертам(Текст, "WARNING", "warning");
	Текст = ДобавитьInlineСтилиКАлертам(Текст, "NOTE", "note");
	Текст = ДобавитьInlineСтилиКАлертам(Текст, "TIP", "tip");
	Текст = ДобавитьInlineСтилиКАлертам(Текст, "IMPORTANT", "important");
	Текст = ДобавитьInlineСтилиКАлертам(Текст, "CAUTION", "caution");

	// 2. Обёртка <div class="markdown-alert">...</div> (без правильного класса) —
	//    добавляем класс markdown-alert-{TYPE} в зависимости от [!TYPE] внутри.
	//    Это покрывает случай, когда JS-extension на живой форме уже создал
	//    обёртку, но без правильного класса. Тоже через простые строковые
	//    операции: ищем <div class="markdown-alert">, проверяем, какой [!TYPE]
	//    внутри, и добавляем нужный класс к открывающему тегу.
	Текст = ДобавитьКлассКMarkdownAlert(Текст);

	ЗаписьЖурналаРегистрации(
		"ГКСИ.MarkdownServer.Alerts.ServerPreprocess",
		УровеньЖурналаРегистрации.Информация, , ,
		"DONE lenBefore=" + Строка(СтрДлина(ТекстДо))
		+ "; lenAfter=" + Строка(СтрДлина(Текст))
		+ "; delta=" + Строка(СтрДлина(Текст) - СтрДлина(ТекстДо))
		+ "; changed=" + Строка(Текст <> ТекстДо));

	Возврат Текст;
КонецФункции

// Гарантирует, что каждый маркер [!TYPE] (WARNING, NOTE, TIP, IMPORTANT,
// CAUTION) находится в начале своего <p> в HTML. Если маркер оказался
// в середине большого <p> (например, после <br> от предыдущей строки),
// перед ним вставляется "</p><p>" — текущий параграф закрывается, и
// открывается новый, начинающийся с маркера.
//
// Зачем: ЗаменитьОбёрткуНаDiv ищет точное "<p>[!TYPE" и не находит маркер,
// если перед ним стоит другой текст. Так бывает, когда HTML пришёл не из
// MarkdownВHTML, а из showdown.js (форма элемента/группы) или из альбома
// процессов — там [!TYPE] без префикса ">" остаётся обычным текстом и
// попадает в общий <p> вместе с соседними строками.
//
// Идемпотентно: если перед [!TYPE] уже стоит "<p>", вставка не выполняется.
// Повторный прогон на уже нормализованном HTML не меняет результат.
//
// Параметры:
//  Текст - Строка - HTML.
//
// Возвращаемое значение:
//  Строка - HTML, в котором каждый [!TYPE] стоит в начале <p>.
//
Функция ОбеспечитьНачалоПараграфаДляМаркеровАлертов(Текст)

	Если НЕ ЗначениеЗаполнено(Текст) Тогда
		Возврат Текст;
	КонецЕсли;

	МассивТипов = Новый Массив;
	МассивТипов.Добавить("WARNING");
	МассивТипов.Добавить("NOTE");
	МассивТипов.Добавить("TIP");
	МассивТипов.Добавить("IMPORTANT");
	МассивТипов.Добавить("CAUTION");

	Результат = Текст;

	Для Каждого ТекТип Из МассивТипов Цикл

		Маркер = "[!" + ТекТип;
		ДлинаМаркера = СтрДлина(Маркер);
		Поз = СтрНайти(Результат, Маркер);

		Пока Поз > 0 Цикл

			// Проверяем, стоит ли маркер уже в начале <p> (три символа "<p>").
			НачалоПараграфаОбеспечено = Ложь;
			Если Поз > 3 Тогда
				СимволыПеред = Сред(Результат, Поз - 3, 3);
				НачалоПараграфаОбеспечено = (СимволыПеред = "<p>");
			КонецЕсли;

			Если НачалоПараграфаОбеспечено Тогда
				// Уже в начале параграфа — просто пропускаем.
				Поз = Поз + ДлинаМаркера;
			ИначеЕсли Поз > 1 Тогда
				// Разрываем текущий параграф и открываем новый перед маркером.
				Результат = Лев(Результат, Поз - 1) + "</p><p>" + Сред(Результат, Поз);
				Поз = Поз + СтрДлина("</p><p>") + ДлинаМаркера;
			Иначе
				// Маркер в самом начале HTML — открываем параграф.
				Результат = "<p>" + Результат;
				Поз = Поз + 3 + ДлинаМаркера;
			КонецЕсли;

			Поз = СтрНайти(Результат, Маркер, , Поз);

		КонецЦикла;

	КонецЦикла;

	Возврат Результат;

КонецФункции

// Возвращает CSS-палитру для указанного суффикса класса алерта
// (note/tip/important/warning/caution) в виде структуры полей
// ЦветБордюра, ЦветФона, ЦветТекста. Значения совпадают с CSS
// .markdown-alert-{type} из шаблона HTMLDocumentField
// (блок .markdown-alert шаблона).
//
// Используется для генерации inline-стилей в HTML, который сохраняется
// в прикреплённый файл сценария — чтобы блок был самодостаточным и
// стилизовался без внешнего CSS (например, в HTMLDocumentField 1С,
// куда подаётся только чистый HTML прикреплённого файла).
//
// Параметры:
//  КлассСуффикс - Строка - суффикс CSS-класса в нижнем регистре.
//
// Возвращаемое значение:
//  Структура - {ЦветБордюра, ЦветФона, ЦветТекста}.
Функция ПалитраАлерта(КлассСуффикс)

	Палитра = Новый Структура;
	Палитра.Вставить("ЦветБордюра", "");
	Палитра.Вставить("ЦветФона", "");
	Палитра.Вставить("ЦветТекста", "");

	Если КлассСуффикс = "note" Тогда
		Палитра.ЦветБордюра = "#0969da";
		Палитра.ЦветФона    = "#ddf4ff";
		Палитра.ЦветТекста  = "#052e6b";
	ИначеЕсли КлассСуффикс = "tip" Тогда
		Палитра.ЦветБордюра = "#1a7f37";
		Палитра.ЦветФона    = "#dafbe1";
		Палитра.ЦветТекста  = "#0d5223";
	ИначеЕсли КлассСуффикс = "important" Тогда
		Палитра.ЦветБордюра = "#8250df";
		Палитра.ЦветФона    = "#f2e8ff";
		Палитра.ЦветТекста  = "#3d1d8a";
	ИначеЕсли КлассСуффикс = "warning" Тогда
		Палитра.ЦветБордюра = "#9a6700";
		Палитра.ЦветФона    = "#fff8c5";
		Палитра.ЦветТекста  = "#6b4f00";
	ИначеЕсли КлассСуффикс = "caution" Тогда
		Палитра.ЦветБордюра = "#cf222e";
		Палитра.ЦветФона    = "#ffebe9";
		Палитра.ЦветТекста  = "#7a121b";
	КонецЕсли;

	Возврат Палитра;

КонецФункции

// Оборачивает содержимое <p>[!TYPE…]</p> в
// <div class="markdown-alert markdown-alert-{type}"
//      style="…inline-стили…">…</div>.
//
// Принципиальное отличие от прежних реализаций: родительский <blockquote>
// НЕ модифицируется и НЕ ищется. Берётся точный фрагмент <p>[!TYPE…]</p>
// и заменяется на <div class="markdown-alert markdown-alert-{type}">…</div>
// с уже разобранным заголовком [!TYPE|Заголовок]. Это исключает любые
// промахи в родителе: класс гарантированно оказывается на <div>, и
// CSS .markdown-alert* применяется к нему напрямую.
//
// В v2.32.9 на <div> и <p class="markdown-alert-title"> дополнительно
// пишутся inline-стили из ПалитраАлерта. Это делает HTML самодостаточным:
// стили алерта применяются в любом HTMLDocumentField (в том числе там,
// куда подаётся только чистый HTML прикреплённого файла без шаблона
// и <style> блока) и в любом стороннем браузере.
//
// Параметры:
//  Текст          - Строка - HTML-текст.
//  ИмяТипа        - Строка - тип алерта (WARNING, NOTE, TIP, IMPORTANT, CAUTION).
//  КлассСуффикс   - Строка - суффикс CSS-класса в нижнем регистре
//                   (warning, note, tip, important, caution).
//
// Возвращаемое значение:
//  Строка - HTML с обёрнутыми алертами.
Функция ЗаменитьОбёрткуНаDiv(Текст, ИмяТипа, КлассСуффикс)

	Если НЕ ЗначениеЗаполнено(Текст) Тогда
		Возврат Текст;
	КонецЕсли;

	Палитра = ПалитраАлерта(КлассСуффикс);
	СтильБлока =
		"padding:8px 16px;"
		+ "margin-bottom:16px;"
		+ "border-left:4px solid " + Палитра.ЦветБордюра + ";"
		+ "border-radius:4px;"
		+ "background-color:" + Палитра.ЦветФона + ";"
		+ "color:" + Палитра.ЦветТекста + ";";
	СтильЗаголовка =
		"font-weight:700;"
		+ "margin:0 0 4px;"
		+ "font-size:0.85em;"
		+ "color:" + Палитра.ЦветТекста + ";";

	НовыйКласс = "markdown-alert markdown-alert-" + КлассСуффикс;
	МаркерП = "<p>[!" + ИмяТипа;

	Результат = Текст;
	ПозМаркера = СтрНайти(Результат, МаркерП);
	Пока ПозМаркера > 0 Цикл

		// Находим границы <p>…</p> вокруг маркера.
		ПозОткрытияП = ПозМаркера - 3; // длина "<p>" = 3
		ПозЗакрытияП = СтрНайти(Результат, "</p>", , ПозМаркера);
		Если ПозОткрытияП > 0 И ПозЗакрытияП > 0 Тогда
			// Содержимое <p>…</p> без обрамляющих тегов.
			СодержимоеП = Сред(Результат, ПозОткрытияП + 3,
				ПозЗакрытияП - ПозОткрытияП - 3);

			// Заменяем [!TYPE] или [!TYPE|Заголовок] на
			// <p class="markdown-alert-title" style="…">…</p>.
			// Trim внешнего <p> не нужен — мы уже вырезали его из HTML.
			СодержимоеП = ЗаменитьМаркерНаЗаголовок(СодержимоеП, ИмяТипа, СтильЗаголовка);

			// Оборачиваем в <div class="…" style="…">…</div>.
			ЧастьДо = Лев(Результат, ПозОткрытияП - 1);
			ЧастьПосле = Сред(Результат, ПозЗакрытияП + 4);
			Результат = ЧастьДо
				+ "<div class=""" + НовыйКласс + """ style=""" + СтильБлока + """>"
				+ СодержимоеП
				+ "</div>"
				+ ЧастьПосле;
		КонецЕсли;

		ПозМаркера = СтрНайти(Результат, МаркерП,
			, ПозОткрытияП + 1);
	КонецЦикла;

	Возврат Результат;

КонецФункции

// Backfill для HTML, обработанного предыдущими версиями: <div class="…">
// уже есть, но без inline-style. Находим такие <div> и дописываем style.
// Идемпотентно — для <div> с уже проставленным style замена не срабатывает,
// потому что ищем точное вхождение "<div class="..." + ">" (без style).
//
// Параметры:
//  Текст         - Строка - HTML.
//  ИмяТипа       - Строка - WARNING, NOTE, TIP, IMPORTANT, CAUTION (не используется).
//  КлассСуффикс  - Строка - warning, note, tip, important, caution.
//
// Возвращаемое значение:
//  Строка - HTML с проставленными inline-стилями на <div class="markdown-alert-…">.
Функция ДобавитьInlineСтилиКАлертам(Текст, ИмяТипа, КлассСуффикс)

	Если НЕ ЗначениеЗаполнено(Текст) Тогда
		Возврат Текст;
	КонецЕсли;

	Палитра = ПалитраАлерта(КлассСуффикс);
	СтильБлока =
		"padding:8px 16px;"
		+ "margin:4px 0 16px;"
		+ "border-left:4px solid " + Палитра.ЦветБордюра + ";"
		+ "border-radius:4px;"
		+ "background-color:" + Палитра.ЦветФона + ";"
		+ "color:" + Палитра.ЦветТекста + ";";

	НовыйКласс = "markdown-alert markdown-alert-" + КлассСуффикс;
	ОткрывающийБезStyle = "<div class=""" + НовыйКласс + """>";
	ОткрывающийСоStyle = "<div class=""" + НовыйКласс + """ style=""" + СтильБлока + """>";

	Результат = Текст;
	Поз = СтрНайти(Результат, ОткрывающийБезStyle);
	Пока Поз > 0 Цикл
		ЧастьДо = Лев(Результат, Поз - 1);
		ЧастьПосле = Сред(Результат, Поз + СтрДлина(ОткрывающийБезStyle));
		Результат = ЧастьДо + ОткрывающийСоStyle + ЧастьПосле;
		Поз = СтрНайти(Результат, ОткрывающийБезStyle, ,
			Поз + СтрДлина(ОткрывающийСоStyle));
	КонецЦикла;

	Возврат Результат;

КонецФункции

// Заменяет в содержимом алерта маркер [!TYPE] или [!TYPE|Заголовок]
// на <p class="markdown-alert-title" style="…">{TYPE или Заголовок}</p>.
// Внешний <p> уже снят вызывающим кодом, поэтому вложенности <p><p> нет.
//
// Параметры:
//  Содержимое   - Строка - текст между <p> и </p>.
//  ИмяТипа      - Строка - WARNING, NOTE, TIP, IMPORTANT, CAUTION.
//  СтильЗаголовка - Строка - inline-style для <p class="markdown-alert-title">.
//
// Возвращаемое значение:
//  Строка - содержимое для вставки в <div class="markdown-alert-…">.
Функция ЗаменитьМаркерНаЗаголовок(Содержимое, ИмяТипа, СтильЗаголовка)
	Если НЕ ЗначениеЗаполнено(Содержимое) Тогда
		Возврат Содержимое;
	КонецЕсли;

	МаркерОткрытия = "[!" + ИмяТипа;
	ПозМаркера = СтрНайти(Содержимое, МаркерОткрытия);
	Если ПозМаркера = 0 Тогда
		Возврат Содержимое;
	КонецЕсли;

	ПозЗакрывающей = СтрНайти(Содержимое, "]", , ПозМаркера);
	Если ПозЗакрывающей = 0 Тогда
		Возврат Содержимое;
	КонецЕсли;

	Внутри = Сред(Содержимое, ПозМаркера + СтрДлина(МаркерОткрытия),
		ПозЗакрывающей - ПозМаркера - СтрДлина(МаркерОткрытия));
	Если Лев(Внутри, 1) = "|" Тогда
		Заголовок = СокрЛП(Сред(Внутри, 2));
		Если Заголовок = "" Тогда
			Заголовок = ИмяТипа;
		КонецЕсли;
	Иначе
		Заголовок = ИмяТипа;
	КонецЕсли;

	ЧастьДо = Лев(Содержимое, ПозМаркера - 1);
	ЧастьПосле = Сред(Содержимое, ПозЗакрывающей + 1);

	Возврат ЧастьДо
		+ "<p class=""markdown-alert-title"" style=""" + СтильЗаголовка + """>" + Заголовок + "</p>"
		+ ЧастьПосле;
КонецФункции

// Добавляет CSS-класс markdown-alert-{TYPE} к открывающему тегу
// <div class="markdown-alert">...</div>, если внутри блока найден маркер
// [!TYPE]. Используется, когда JS-extension на живой форме создал обёртку
// без правильного класса. Тоже простой обход через СтрНайти.
//
// Параметры:
//  Текст - Строка - HTML-текст.
//
// Возвращаемое значение:
//  Строка - HTML с добавленными классами.
Функция ДобавитьКлассКMarkdownAlert(Текст)
	// Поведение объединено с ЗаменитьОбёрткуНаDiv: новый алгоритм
	// умеет находить и <blockquote>, и <div class="markdown-alert">,
	// добавляя к ним недостающий класс markdown-alert-{TYPE}.
	// Отдельный проход больше не нужен.
	Возврат Текст;
КонецФункции

// Обрабатывает синтаксис переопределения заголовка алерта:
//   [!TYPE|Заголовок]   →   <p class="markdown-alert-title">Заголовок</p>
//
// Если в содержимом найден маркер [!TYPE] БЕЗ переопределения — возвращает
// исходный текст без изменений. Если после [!TYPE] идёт | — извлекает
// заголовок, удаляет весь блок [!TYPE|Заголовок] и вставляет готовый
// <p class="markdown-alert-title">. Совпадает с поведением JS-extension
// gksi-alerts.
//
// Параметры:
//  Содержимое - Строка - HTML внутри <blockquote> или <div class="markdown-alert">.
//  ИмяТипа    - Строка - WARNING, NOTE, TIP, IMPORTANT или CAUTION.
//
// Возвращаемое значение:
//  Строка - HTML с обработанным заголовком.
Функция ОбработатьЗаголовокАлерта(Содержимое, ИмяТипа)
	Если НЕ ЗначениеЗаполнено(Содержимое) Тогда
		Возврат Содержимое;
	КонецЕсли;

	Маркер = "[!" + ИмяТипа;
	ПозМаркера = СтрНайти(Содержимое, Маркер);
	Если ПозМаркера = 0 Тогда
		Возврат Содержимое;
	КонецЕсли;

	ПозЗакрывающей = СтрНайти(Содержимое, "]", , ПозМаркера);
	Если ПозЗакрывающей = 0 Тогда
		Возврат Содержимое;
	КонецЕсли;

	// Внутри скобок: "[!TYPE" уже отбросили, осталось "|Заголовок" или "".
	ТекстМежду = Сред(Содержимое, ПозМаркера + СтрДлина(Маркер),
		ПозЗакрывающей - ПозМаркера - СтрДлина(Маркер));
	Если Лев(ТекстМежду, 1) <> "|" Тогда
		Возврат Содержимое;
	КонецЕсли;

	Заголовок = СокрЛП(Сред(ТекстМежду, 2));
	Если Заголовок = "" Тогда
		Возврат Содержимое;
	КонецЕсли;

	// Showdown оборачивает содержимое blockquote в <p>...</p>. Если просто
	// вставить сюда <p class="markdown-alert-title">, получится вложенный
	// <p><p ...> — браузер выкидывает вложенный тег, и стили заголовка
	// не применяются. Поэтому сначала снимаем внешнюю обёртку <p>...</p>.
	ПозПервогоОткрывающегоП = СтрНайти(Содержимое, "<p>");
	Если ПозПервогоОткрывающегоП > 0 Тогда
		Содержимое = СокрЛ(Сред(Содержимое, ПозПервогоОткрывающегоП + 3));
	КонецЕсли;
	ПозПоследнегоЗакрывающегоП = 0;
	ПозПоиска = 1;
	Пока Истина Цикл
		Поз = СтрНайти(Содержимое, "</p>", , ПозПоиска);
		Если Поз = 0 Тогда
			Прервать;
		КонецЕсли;
		ПозПоследнегоЗакрывающегоП = Поз;
		ПозПоиска = Поз + 1;
	КонецЦикла;
	Если ПозПоследнегоЗакрывающегоП > 0 Тогда
		Содержимое = СокрП(Лев(Содержимое, ПозПоследнегоЗакрывающегоП - 1));
	КонецЕсли;

	// Пересчитать позицию маркера после снятия <p>-обёртки.
	ПозМаркера = СтрНайти(Содержимое, Маркер);
	Если ПозМаркера = 0 Тогда
		Возврат Содержимое;
	КонецЕсли;
	ПозЗакрывающей = СтрНайти(Содержимое, "]", , ПозМаркера);
	Если ПозЗакрывающей = 0 Тогда
		Возврат Содержимое;
	КонецЕсли;

	ЧастьДо = Лев(Содержимое, ПозМаркера - 1);
	ЧастьПосле = Сред(Содержимое, ПозЗакрывающей + 1);

	Возврат ЧастьДо + "<p class=""markdown-alert-title"">" + Заголовок + "</p>"
		+ ЧастьПосле;
КонецФункции

Функция ЭлементФормы(Форма, Идентификатор) Экспорт
	Если ТипЗнч(Идентификатор) = Тип("Строка") Тогда
		Возврат Форма.Элементы.Найти(Идентификатор);
	Иначе
		Возврат Идентификатор;
	КонецЕсли;
КонецФункции

Функция Реквизит(Форма, ИмяРеквизита, ПутьКРеквизиту = "") Экспорт
	Если ПутьКРеквизиту <> "" Тогда
		Разделитель = СтрНайти(ПутьКРеквизиту, ".");
		Если Разделитель = 0 Тогда
			ИмяШага = ПутьКРеквизиту;
			ОстатокПути = "";
		Иначе
			ИмяШага = Лев(ПутьКРеквизиту, Разделитель - 1);
			ОстатокПути = Сред(ПутьКРеквизиту, Разделитель + 1);
		КонецЕсли;
		Возврат Реквизит(Форма[ИмяШага], ИмяРеквизита, ОстатокПути);
	Иначе
		НесуществующееЗначение = Неопределено;
		Структура = Новый Структура(ИмяРеквизита, НесуществующееЗначение);
		ЗаполнитьЗначенияСвойств(Структура, Форма);
		Если Структура[ИмяРеквизита] = НесуществующееЗначение Тогда
			Возврат НесуществующееЗначение;
		КонецЕсли;
		Возврат Форма[ИмяРеквизита];
	КонецЕсли;
КонецФункции

#КонецОбласти