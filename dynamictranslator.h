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

#ifndef DYNAMICTRANSLATOR_H
#define DYNAMICTRANSLATOR_H

#include <QObject>
#include <QApplication>
#include <QtCore/QTranslator>

class DynamicTranslator : public QObject
{
    Q_OBJECT     
    Q_PROPERTY(QString emptyString READ getEmptyString NOTIFY languageChanged)

public:
    explicit DynamicTranslator(QApplication *app,  QObject *parent = 0);

    QString getEmptyString();
    Q_INVOKABLE void selectLanguage(const QString &language);
    
signals:
    void languageChanged();

private:
    QApplication *p_app;
    QTranslator p_translator;

};

#endif // DYNAMICTRANSLATOR_H
