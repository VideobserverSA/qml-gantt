/****************************************************************************
**
** Copyright (C) 2015-2016 Dinu SV.
** (contact: mail@dinusv.com)
** This file is part of QML Gantt library.
**
** GNU Lesser General Public License Usage
** This file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
****************************************************************************/

#include "qganttmodellist.h"
#include "qganttmodel.h"

#include <QDebug>
#include <QtGlobal>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

class QGanttModelContainer{
public:
    ~QGanttModelContainer(){ delete model; }

    QString      name;
    QGanttModel* model;
};


QGanttModelList::QGanttModelList(QObject* parent)
    : QAbstractListModel(parent)
{
    m_zoomFactor = 1LL;
}

QGanttModelList::QGanttModelList(qint64 size, QObject *parent)
    : QAbstractListModel(parent)
    , m_contentWidth(size)
{
}

QGanttModelList::~QGanttModelList(){
    clearAll();
}

QVariant QGanttModelList::data(const QModelIndex &index, int role) const{
    if ( index.row() >= m_items.size() )
        return QVariant();
    if ( role == QGanttModelList::Name )
        return m_items[index.row()]->name;
    else if ( role == QGanttModelList::GanttModel )
        return QVariant::fromValue(m_items[index.row()]->model);
    else
        return QVariant();
}

bool QGanttModelList::setData(const QModelIndex &index, const QVariant &value, int role){
    if ( index.row() >= m_items.size() )
        return false;
    if ( role == QGanttModelList::Name ){
        m_items[index.row()]->name = value.toString();
        emit dataChanged(index, index, QVector<int>() << role);
        return true;
    } else
        return false;
}

QHash<int, QByteArray> QGanttModelList::roleNames() const{
    QHash<int, QByteArray> rolenames;
    rolenames[Name]       = "name";
    rolenames[GanttModel] = "ganttModel";
    return rolenames;
}

void QGanttModelList::clearAll(){
    for ( QList<QGanttModelContainer*>::Iterator it = m_items.begin(); it != m_items.end(); ++it )
        delete *it;
    m_items.clear();
}

void QGanttModelList::appendModel(QGanttModel *model){
    QGanttModelContainer* item = new QGanttModelContainer;
    item->model = model;
    item->name  = "Gantt Row #" + QString::number(m_items.size());
    m_items.append(item);
}

bool QGanttModelList::insertRows(int row, int count, const QModelIndex &parent){
    beginInsertRows(parent, row, row + count - 1);
    for ( int i =  row; i < row + count - 1; ++i ){
        QGanttModelContainer* item = new QGanttModelContainer;
        item->model = new QGanttModel;
        item->model->setContentWidth(m_contentWidth);
        item->name  = "Gantt Row";
        m_items.insert(i, item);
    }
    endInsertRows();
    return true;
}

bool QGanttModelList::removeRows(int row, int count, const QModelIndex &parent){
    beginRemoveRows(parent, row, row + count - 1);
    for ( int i = row + count - 1; i <= row; --i )
        m_items.removeAt(i);
    endRemoveRows();
    return true;
}

void QGanttModelList::moveItem(QString uuid, QString direction)
{
    //qDebug() << "item uuid" << uuid << "direction" << direction;
    // find the index of the current item
   // qDebug() << "so how many fucking items" << m_items.count();
    int itemCurrentIndex = 0;
    for(int i = 0; i < m_items.count(); i++) {
        QGanttModelContainer *container = m_items.at(i);
        QGanttModelItem* testModel = container->model->searchByUuid(uuid);
        if(testModel != NULL) {
            itemCurrentIndex = i;
        }
    }
    int itemNewIndex = 0;
    // check the new index
    if(direction == "up") {
        itemNewIndex = itemCurrentIndex - 1;
    } else {
        itemNewIndex = itemCurrentIndex + 1;
    }

    if(itemNewIndex < 0 || itemNewIndex > (m_items.count() - 1)) {
        qDebug() << "NO WAY ABORT";
        return;
    }

    // then do the switcharoo
    QGanttModelItem* theItem = m_items.at(itemCurrentIndex)->model->removeItem(uuid);
    m_items.at(itemNewIndex)->model->insertItem(theItem);

    //qDebug() << "the fucking new index is:" << theItem;

}

QJsonDocument QGanttModelList::exportModelToJson()
{
    QJsonDocument ret = QJsonDocument();
    QJsonArray finalArray = QJsonArray();
    //ret->insert("rows", finalArray);

    for(int i = 0; i < m_items.count(); i++) {
        QGanttModelContainer *container = m_items.at(i);
        // put the name
        QJsonObject contJson = QJsonObject();
        contJson.insert("name", container->name);
        // get the model array?
        QJsonArray modelJson  =container->model->exportModelToJson();
        contJson.insert("model", modelJson);

        // insert in the arr
        finalArray.append(contJson);


        //QGanttModelItem* testModel = container->model->searchByUuid(uuid);
        //if(testModel != NULL) {
        //    itemCurrentIndex = i;
        //}
    }

    ret.setArray(finalArray);
    qDebug() << "FDX" << ret.toJson(QJsonDocument::Compact);
    return ret;
}

/*void QGanttModelList::zoomIn()
{
    // 8LL = 8 long long
    m_zoomFactor = qMin(8LL, m_zoomFactor + 1);
    emit zoomFactorChanged(m_zoomFactor);
}

void QGanttModelList::zoomOut()
{
    m_zoomFactor = qMax(1LL, m_zoomFactor - 1);
    emit zoomFactorChanged(m_zoomFactor);
}*/

