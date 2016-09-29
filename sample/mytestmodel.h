#ifndef MYTESTMODEL_H
#define MYTESTMODEL_H

#include <QObject>
#include <QVector>
#include <QMap>
#include <QJsonObject>
#include "qganttmodelitem.h"

class MyTestModel : public QObject
{
    Q_OBJECT
    QVector<QMap<QString, QGanttModelItem*>> m_model;

public:
    explicit MyTestModel(QObject *parent = 0);
    void insertItem(int index, QGanttModelItem* item);
    QGanttModelItem* getItem(QString uuid);
    Q_INVOKABLE QJsonObject toJson();
    Q_INVOKABLE QString toJsonString();

signals:

public slots:
};

#endif // MYTESTMODEL_H
