/*
 * Copyright (C) 2016 The Qt Company Ltd.
 * Copyright (C) 2016,2017,2019,2022 Konsulko Group
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <QtCore/QDebug>
#include <QtCore/QSettings>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtQuickControls2/QQuickStyle>
#include <QQuickWindow>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <RadioClient.h>
#include "PresetDataObject.h"

#define APP_DATA_PRESETS_PATH "/app-data/radio/presets.conf"

int main(int argc, char *argv[])
{
	QString graphic_role = QString("radio");

	QGuiApplication app(argc, argv);
	app.setDesktopFileName(graphic_role);

	QQuickStyle::setStyle("AGL");

	// Read presets from configuration file
	//
	// If HOME is set, use $HOME/app-data/radio/presets.conf if it exists,
	// else fall back to the QSettings default locations with organization
	// "AGL" and a file name of radio-presets.conf. See:
	//
	// http://doc.qt.io/qt-5/qsettings.html#platform-specific-notes
	//
	// for details on the locations and their order of priority.
	//
	QSettings *pSettings = NULL;
	char *p = getenv("HOME");
	bool settingsFound = false;
	if (p)
	{
		struct stat statbuf;
		std::string presets(p);
		presets += APP_DATA_PRESETS_PATH;
		if (stat(presets.c_str(), &statbuf) == 0)
		{
			QString confPath = p;
			confPath.append(APP_DATA_PRESETS_PATH);
			pSettings = new QSettings(confPath, QSettings::NativeFormat);
			settingsFound = true;
		}
	}
	if (!settingsFound)
	{
		pSettings = new QSettings("AGL", "radio-presets");
	}

	QList<QObject *> presetDataList;
	int size = pSettings->beginReadArray("fmPresets");
	for (int i = 0; i < size; ++i)
	{
		pSettings->setArrayIndex(i);
		presetDataList.append(new PresetDataObject(pSettings->value("title").toString(),
												   pSettings->value("frequency").toInt(),
												   1));
	}
	pSettings->endArray();

	QQmlApplicationEngine engine;
	QQmlContext *context = engine.rootContext();
	context->setContextProperty("presetModel", QVariant::fromValue(presetDataList));
	context->setContextProperty("radio", new RadioClient(context));
	engine.load(QUrl(QStringLiteral("qrc:/Radio.qml")));
	return app.exec();
}
