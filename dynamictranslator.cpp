/* Copyright © mangolazi 2013.
This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

// Allows dynamic loading of translator files when assigned to QML rootcontext
// and with + rootItem.emptyString to each QML item's text property

#include "dynamictranslator.h"
#include <QtCore/QTranslator>

DynamicTranslator::DynamicTranslator(QApplication *app, QObject *parent) :
    QObject(parent),
    p_app(app)
{
}

QString DynamicTranslator::getEmptyString() {
    return "";
}

void DynamicTranslator::selectLanguage(const QString &language) {
    if (p_translator.load("lang_" + language, ":/i8n")) {
       p_app->removeTranslator(&p_translator);
       p_app->installTranslator(&p_translator);
    }
    emit languageChanged();
 }
