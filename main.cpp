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

#include <QtGui/QApplication>
#include <QDeclarativeView>
#include <QDeclarativeContext>

#include <QtCore/QTranslator>
#include <QtCore/QLocale>
#include "dynamictranslator.h"

int main(int argc, char *argv[])
{
 QApplication app(argc, argv);

 // find locale, load translation for locale
 // language override will happen in MainPage.QML
 QString locale = QLocale::system().name();
 locale.truncate(2);
 QString filename = QString("lang_") + locale;

 static QTranslator translator;
 if( translator.load(filename, ":/i8n") ){
     app.installTranslator(&translator);
 } else {
     // load English default
     translator.load("lang_en", ":/i8n");
     app.installTranslator(&translator);
 }

 //QDeclarativeContext *context = view.rootContext();
 //context->setContextProperty("backgroundColor", QColor(Qt::yellow));

 DynamicTranslator dyntranslator(&app);

 QDeclarativeView view;
 view.rootContext()->setContextProperty("rootItem", &dyntranslator);

 view.setSource(QUrl::fromLocalFile("qml/WeatherMango/main.qml"));
 view.setAttribute(Qt::WA_NoSystemBackground);
 view.show();

 return app.exec();
}


// =============================================
// old style
/*
Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));

    QString locale = QLocale::system().name();
    locale.truncate(2);
    QString filename = QString("lang_") + locale;
    qDebug() << "Locale is " << locale;

    static QTranslator translator;
    if( translator.load(filename, ":/i8n") ){
        app->installTranslator(&translator);
        qDebug() << "Translation loaded" << filename;
    } else {
        // load English default
        itranslator.load("lang_en", ":/i8n");
        app->installTranslator(&translator);
        qDebug() << "Defaulting to English, translation not loaded:" << filename;
    }

    QmlApplicationViewer viewer;
    viewer.setMainQmlFile("qml/WeatherMango/main.qml");
    viewer.setAttribute(Qt::WA_NoSystemBackground);
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);

    viewer.showExpanded();

    return app->exec();
}
*/
