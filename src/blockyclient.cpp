/*
  The MIT License (MIT)

  Copyright (c) 2023 Andrea Scarpino <andrea@scarpino.dev>

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
*/

#include "blockyclient.h"

#include <QDir>
#include <QStandardPaths>
#include <QCoreApplication>
#include <QEventLoop>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QSettings>
#include <QUrl>
#include <QUrlQuery>

BlockyClient::BlockyClient(QObject *parent)
    : QObject(parent)
    , m_network(new QNetworkAccessManager(this))
{
    m_settingsPath = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation)
                     + QDir::separator() + QCoreApplication::applicationName()
                     + ".conf";
}

BlockyClient::~BlockyClient()
{
}

bool BlockyClient::disableBlocking(int durationSeconds)
{
    QSettings settings(m_settingsPath, QSettings::IniFormat);
    if (!settings.value(QStringLiteral("apiEnabled"), true).toBool()) {
        return false;
    }

    QUrl url(QStringLiteral("http://localhost:4000/api/blocking/disable"));

    QUrlQuery query;
    query.addQueryItem(QStringLiteral("duration"), QStringLiteral("%1s").arg(durationSeconds));
    url.setQuery(query);

    QNetworkRequest req(url);
    QNetworkReply *reply = m_network->get(req);

    QEventLoop loop;
    connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    bool success = reply->error() == QNetworkReply::NoError;
    reply->deleteLater();

    return success;
}

bool BlockyClient::enableBlocking()
{
    QSettings settings(m_settingsPath, QSettings::IniFormat);
    if (!settings.value(QStringLiteral("apiEnabled"), true).toBool()) {
        return false;
    }

    QUrl url(QStringLiteral("http://localhost:4000/api/blocking/enable"));

    QNetworkRequest req(url);
    QNetworkReply *reply = m_network->get(req);

    QEventLoop loop;
    connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    bool success = reply->error() == QNetworkReply::NoError;
    reply->deleteLater();

    return success;
}
