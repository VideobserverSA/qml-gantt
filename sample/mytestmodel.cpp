#include "mytestmodel.h"
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

MyTestModel::MyTestModel(QObject *parent) : QObject(parent)
{
    // start with 5 rows at begining
    m_model = QVector<QMap<QString, QGanttModelItem*>>(0);
}

void MyTestModel::insertItem(int index, QGanttModelItem *item)
{
    // dow we have the row?
    if(index >= m_model.length()) {
        m_model.resize(index + 1);
    }
    QMap<QString, QGanttModelItem*> testMap = m_model.at(index);
    testMap.insert(item->uuid(), item);
    m_model[index] = testMap;
}

QGanttModelItem *MyTestModel::getItem(QString uuid)
{
    for(QMap<QString, QGanttModelItem*> testMap : m_model) {
        if(testMap.contains(uuid)) {
            return testMap.value(uuid);
        }
    }

    return NULL;
}

QJsonObject MyTestModel::toJson()
{
    QJsonObject ret = QJsonObject();
    QJsonArray retArr = QJsonArray();

    for(QMap<QString, QGanttModelItem*> testMap : m_model) {

        QJsonArray row = QJsonArray();
        QMapIterator<QString, QGanttModelItem*> iterator(testMap);
        while(iterator.hasNext()) {
            iterator.next();
            QGanttModelItem* item = iterator.value();
            QJsonObject itemJson = QJsonObject();
            itemJson.insert("uuid", item->uuid());
            itemJson.insert("pos", item->position());
            row.append(itemJson);
        }
        retArr.append(row);
    }
    ret.insert("model", retArr);
    return ret;
}

QString MyTestModel::toJsonString()
{
    QJsonDocument doc = QJsonDocument();
    doc.setObject(toJson());
    return doc.toJson();
}
